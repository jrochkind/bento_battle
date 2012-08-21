require 'test_helper'

class BattleControllerTest < ActionController::TestCase
  #test "should get index" do
  #  get :index
  #  assert_response :success
  #end
  
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
