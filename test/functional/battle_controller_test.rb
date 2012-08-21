require 'test_helper'

class BattleControllerTest < ActionController::TestCase
  def setup
    BentoSearch.register_engine("AA") do |conf|
      conf.engine = "BentoSearch::MockEngine"
    end
    BentoSearch.register_engine("BB") do |conf|
      conf.engine = "BentoSearch::MockEngine"
    end
    BentoSearch.register_engine("CC") do |conf|
      conf.engine = "BentoSearch::MockEngine"
    end
      
    BattleController.contenders = ["AA", "BB", "CC"]
  end
  
  def teardown
    BattleController.contenders = nil
    BentoSearch.reset_engine_registrations!
  end
  
  
  test "should get index" do
    get :index
    
    assert_response :success   
    
    assert ! assigns["results"]
  end
  
  test "should get index with results" do
    get :index, :q => "Cancer"
    
    assert_response :success  
    
    assert      assigns["one"], "assigns @one"
    assert      assigns["two"], "assigns @two"
    
    results     = assigns["results"]
    
    assert      results, "assigns @results"
            
    assert_kind_of Hash, results
    assert_equal 2, results.size, "@results has two values"
    
    results.values.each do |v|
      assert_kind_of BentoSearch::Results, v, "each results value is a BentoSearch::Results"
    end
  end
  
  test "should recover from errors when searching" do
    BentoSearch.register_engine("error") do |conf|
      conf.engine = "BentoSearch::MockEngine"
      conf.error = {:message => "Fake error"}
    end
    BattleController.contenders = ["AA", "BB", "CC", "error"]
    
    # Fake it into 'randomly' picking error in it's first two please
    @controller.extend( Module.new do      
      # chooses from the end, so put error at the end
      def choices
        @choices ||= ["AA", "BB", "error", "CC"]
      end
    end)
    
    assert_difference("Error.count", 1) do
      get :index, :q => "Cancer"
    end
    
    assert_response :success  
    
    # proper error was saved
    err = Error.last
    assert_equal "error", err.engine

    
    # didn't use error, replaced it with next in list, BB
    assert_equal "CC", assigns["one"]
    assert_equal "BB", assigns["two"]
    
    # and in results
    assert_include assigns["results"].keys, "CC"
    assert_include assigns["results"].keys, "BB"
    
    # and neither are errors
    assert ! assigns["results"].values.find {|r| r.failed?}
    
  end
  
  test "choice" do
    option_a = ["a", "b", "c"].sample
    option_b = ["1", "2", "3"].sample    
    
    assert_difference("Selection.count", 1) do
      post :choice, example_post_params.merge(:option_a => option_a, :option_b => option_b)      
    end
    
    assert_redirected_to root_path
    assert flash[:submitted]
    
    last = Selection.order("created_at DESC").first
    
    assert_equal option_a, last.option_a
    assert_equal option_b, last.option_b
    
    assert_equal option_a, last.choice    
  end
  
  test "demographics saved on choice" do
    assert_difference("Selection.count", 1) do
      post :choice, example_post_params
    end
    
    last = Selection.order("created_at DESC").first
    
    assert_equal "Some School", last.demographic_school
    assert_equal "Undergraduate", last.demographic_status     
  end
  
  test "should error if insufficient params" do
    assert_no_difference("Selection.count") do
      post :choice
    end
    
    assert_response :error
  end
  
  test "should save timing info" do
    assert_difference("Timing.count", 2) do
      post :choice, example_post_params
    end      
    
    last_two = Timing.last(2)
    
    assert( last_two.find do |t| 
      t.engine == example_post_params[:option_a] && 
        t.miliseconds == example_post_params[:timing_a]
    end, "timing_a recorded")
    assert( last_two.find do |t| 
      t.engine == example_post_params[:option_b] &&
      t.miliseconds == example_post_params[:timing_b]
    end, "timing_b recorded")
  end
  
    

  def example_post_params
    {
      :option_a => "one", :option_b => "two", :preferA => "submit", :query => "foo", :school => "Some School", :status => "Undergraduate", 
      :timing_a => 1000,
      :timing_b => 2000
     }
  end
  
end
