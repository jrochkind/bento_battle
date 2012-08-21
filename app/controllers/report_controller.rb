class ReportController < ApplicationController
  
  def index
    @results = fetch_stats
    @match_up_keys, @match_up_count = fetch_sanity_check_grid 
    @demographic_overview = fetch_demographic_overview    
    
    @timings = fetch_timing
    
    @errors = fetch_errors
    
    @total_selections = Selection.count
  end
  
  protected
  
  # pass in a hash representing a row, returned by fetch_stats
  # calc the 'victory rate': wins / (wins + losses), disregarding ties,
  # expressed as a percentage
  def victory_rate(row)
    100 * row["wins"].to_f / ( row["wins"] + row["losses"] ) 
  end
  helper_method :victory_rate
  
  # Yeah, because of the way we are storing each data element, we need
  # some wacky SQL to fetch em. But I still suspect there isn't a cleaner
  # way to do this, would be exchanging one set of problems for another
  # to alter schema. 
  #
  # We'll just use straight SQL, too confusing to try to activerecord-ize
  # this with little gain. 
  def fetch_stats
    sql = 
      <<-EOS
      SELECT engine, 
             count(*) as total_selections, 
             sum(win) as wins, 
             sum(tie) as ties, 
             sum(loss) as losses 
      FROM (
  
        SELECT option_a AS engine, 
               (case when option_a = choice then 1 else 0 end) as win, 
               (case when choice is NULL then 1 else 0 end) as tie, 
               (case when option_b = choice then 1 else 0 end) AS loss 
        FROM selections
  
        UNION ALL
  
        SELECT option_b AS engine, 
              (case when option_b = choice then 1 else 0 end) as win, 
              (case when choice is NULL then 1 else 0 end) as tie, 
              (case when option_a = choice then 1 else 0 end) AS loss
        FROM selections 
  
     )
  
     GROUP BY engine
   EOS
   
   return Selection.connection.select_all( sql ).sort_by {|r| victory_rate(r)}.reverse    
  end
  
  # again some raw sql, a grid of how often each engine was faced
  # off against each other engine in a match that resulted in
  # a a/b/tie selection. 
  def fetch_sanity_check_grid
    results = Selection.connection.select_all("select option_a, option_b, count(*) as count from selections group by option_a, option_b")
    # we get back pairings that are A vs B in one row, and B vs A in a different one. Combine em all. 
    
    match_ups = Hash.new do |h, k|
      h[k] = Hash.new(0)
    end

    results.each do |row|
      normal = [row["option_a"], row["option_b"]].sort
      match_ups[normal.first][normal.last] += row["count"]
      match_ups[normal.last][normal.first] += row["count"]
    end
    
    engines = Selection.connection.
      select_all("select option_a as engine from selections union select option_b as engine from selections").
      collect {|row| row["engine"]}

    return engines, match_ups
    
  end
  
  def fetch_demographic_overview
    sql = <<-EOS
      select demographic_school, demographic_status, count(*) as count
      from selections 
      group by demographic_school, demographic_status
      
      union all
      
      select demographic_school, "TOTAL" as demographic_status, count(*) as count
      from selections
      group by demographic_school
      
      union all
      
      select "TOTAL" as demographic_school, demographic_status, count(*) as count
      from selections
      group by demographic_status
      EOS
      
      results = Selection.connection.select_all(sql)

      return results
  end
  
  def fetch_timing
    # we have to do multiple fetches so we can get percentiles
    timings = Timing.calculate("average", "miliseconds", :group => "engine")
    
    # make values a hash with that as mean, so we can add percentiles
    timings.keys.each do |key|
      timings[key] = {"mean" => timings[key]}
    end
    
    Timing.calculate("count", nil, :group => "engine").each_pair do |engine, count|
      timings[engine]["count"] = count
    end
    
    Timing.calculate("maximum", "miliseconds", :group=> "engine").each_pair do |engine, max|
      timings[engine]["max"] = max
    end
    
    timings.each_pair do |engine, data|
      data["median"] = Timing.where("engine" => engine).order("miliseconds").limit(1).offset( data["count"] / 2  ).first.miliseconds
      data["percentile90"] = Timing.where("engine" => engine).order("miliseconds desc").limit(1).offset( data["count"] / 10  ).first.miliseconds
    end    
    
  end
  
  def fetch_errors
    Error.calculate("count", nil, :group => "engine")
  end
  
  
end
