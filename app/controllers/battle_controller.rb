class BattleController < ApplicationController
  
  def self.contenders       
    @@contenders ||= $battle_engines # defined in initializer with engines    
  end
  def contenders ; self.class.contenders ; end
  
  # settable mainly for testing purposes, ordinarily will be lazily
  # loaded from $battle_engines global. 
  def self.contenders=(arr)
    @@contenders = arr
  end
  
  before_filter :validate_choice, :only => :choice
  
  def index
    if params[:q]            
      @one = choices.pop
      @two = choices.pop
      
      searcher = BentoSearch::MultiSearcher.new(@one, @two)      

      @results = searcher.start(params[:q]).results 
      
      # check for failed searches and handle
      ["one", "two"].each do |choice|
        engine = instance_variable_get("@#{choice}")        
        if @results[engine].failed?
          handle_failed_results(choice)
        end
      end      
    end    
  end
  
  
  
  def choice    
    choice = if params["preferA"].present?
      params[:option_a]
    elsif params["preferB"].present?
      params[:option_b]
    elsif params["preferNone"].present?
      nil
    else
      raise Exception.new("Missing choice in request params")
    end
    
    selection = Selection.new
    
    selection.query               = params[:query]
    selection.option_a            = params[:option_a]
    selection.option_b            = params[:option_b]
    selection.choice              = choice
    
    session[:school_choice] = selection.demographic_school  = params[:school]
    session[:status_choice] = selection.demographic_status  = params[:status]

    selection.save!

    Timing.create(:engine => params[:option_a], :miliseconds => params[:timing_a])
    Timing.create(:engine => params[:option_b], :miliseconds => params[:timing_b])
    
    redirect_to root_path, :flash => {:submitted => true}
  end
  
  protected
  
  # in seperate method mainly so we can mock it in tests to choose
  # exactly what engines we want. 
  def choices
    @choices ||= contenders.shuffle
  end
  
  def validate_choice
    unless (params[:option_a].present? && params[:option_b].present? &&
      params[:query].present? &&
      (params['preferB'].present? || params['preferA'].present? || params['preferNone'].present?)  &&
      params[:timing_a].present? && params[:timing_b].present?)
    
      render :status => 500, :text => "ERROR: missing input. Something is wrong, your choice was not recorded."
    
    end
  end
  
  # arg 'choice' is 'one' or 'two', and is a search engine results
  # that failed. We'll try to replace it with results from next in
  # list, and register it's failure. Check again and recursively
  # handle error again if needed. 
  def handle_failed_results(choice)
    orig_engine = instance_variable_get("@#{choice}")
    orig_results = @results[orig_engine]
    
    # record the error
    Error.create(
      :engine => orig_engine, 
      :error_info => orig_results.error.to_hash,
      :backtrace => orig_results.error[:exception].try(:backtrace) 
     )
    
    
    @results.delete orig_engine
    
    new_engine = choices.pop
    instance_variable_set("@#{choice}", new_engine)
    
    new_results = BentoSearch.get_engine(new_engine).search(params[:q])
    
    @results[new_engine] = new_results    
    
    # if it's still failed, do it again!
    if new_results.failed?
      handle_failed_results(choice)
    end    
  end
  
end
