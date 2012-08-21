class BattleController < ApplicationController
  
  def self.contenders    
    @@contenders ||= $battle_engines # defined in initializer with engines    
  end
  
  # settable mainly for testing purposes, ordinaril
  def self.contenders=(arr)
    @@contenders = arr
  end
  
  before_filter :validate_choice, :only => :choice
  
  def index
    if params[:q]
      choices = @@contenders.shuffle
      
      @one = choices.pop
      @two = choices.pop
      
      searcher = BentoSearch::MultiSearcher.new(@one, @two)      

      @results = searcher.start(params[:q]).results            
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
    
    redirect_to root_path, :flash => {:submitted => true}
  end
  
  protected
  
  def validate_choice
    unless (params[:option_a].present? && params[:option_b].present? &&
      params[:query].present? &&
      (params['preferB'].present? || params['preferA'].present? || params['preferNone'].present?)  &&
      params[:timing_a].present? && params[:timing_b].present?)
    
      render :status => 500, :text => "ERROR: missing input. Something is wrong, your choice was not recorded."
    
    end
  end
  
end
