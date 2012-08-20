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
      post :choice, :option_a => option_a, :option_b => option_b, :preferA => "submit", :query => "foo"      
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
      post :choice, :option_a => "A", :option_b => "B", :preferA => "submit", :query => "foo", :school => "Some School", :status => "Undergraduate"
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

  def choice_params
    
  end
  
end
