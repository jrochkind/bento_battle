class ReportController < ApplicationController
  
  def index
    @results = fetch_stats
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
  
end
