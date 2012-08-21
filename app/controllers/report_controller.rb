class ReportController < ApplicationController
  
  def index
    @results = fetch_stats
    @match_up_keys, @match_up_count = fetch_sanity_check_grid 
    @demographic_overview = fetch_demographic_overview    
  end
  
  protected
  
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
   
   return Selection.connection.select_all( sql )      
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
  
end
