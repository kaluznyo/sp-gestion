require 'test_helper'

class UniformsControllerTest < ActionController::TestCase
  setup(:activate_authlogic)

  context "an user logged in" do
    setup do
      login
    end
    
    context "requesting index" do
      setup do
        get :index
      end

      should_respond_with(:success)
      should_render_template("index")
      should_render_with_layout("back")
      
      should_assign_to(:uniforms)
    end    
    
    context "requesting a non existing uniform" do
      setup do
        get :show, :id => rand(10)
      end
      
      should_respond_with(:redirect)
      should_redirect_to(":index") { uniforms_path }

      should_set_the_flash(:error)
    end    
        
    context "requesting GET :new" do
      setup do
        get :new
      end

      should_respond_with(:success)
      should_render_template("new")
      should_render_with_layout("back")
    end
    
    context "requesting POST with bad data" do
      setup do
        post :create, :uniform => {:title => '', :code => '2b', :description => 'test'}
      end
    
      should_respond_with(:success)
      should_render_template("new")
      should_render_with_layout("back")
      
      should_not_change("number of uniforms") { Uniform.count }
    end   
    
    context "requesting POST with good data" do
      setup do
        post :create, :uniform => Uniform.plan
      end
    
      should_respond_with(:redirect)
      should_redirect_to("uniform") { uniform_path(assigns(:uniform)) }
      
      should_assign_to(:uniform)
      should_change("number of uniform", :by => 1) { Uniform.count }

      should_set_the_flash(:success)
    end    
    
    context "with an existing uniform" do
      setup do
        @uniform = @station.uniforms.make
      end
  
      context "requesting GET on existing uniform" do
        setup do
          get :show, :id => @uniform.id
        end
  
        should_respond_with(:success)
        should_render_template("show")
        should_render_with_layout("back")
      end
      
      context "requesting GET :edit" do
        setup do
          get :edit, :id => @uniform.id
        end
  
        should_respond_with(:success)
        should_render_template("edit")
        should_render_with_layout("back")
      end  
      
      context "requesting PUT with bad data" do
        setup do
          put :update, :id => @uniform.id, :uniform => {:title => '', :code => '2b', :description => 'test'}
        end
  
        should_respond_with(:success)
        should_render_template("edit")
        should_render_with_layout("back")
      end  
      
      context "requesting PUT with good data" do
        setup do
          put :update, :id => @uniform.id, :uniform => Uniform.plan
        end
  
        should_respond_with(:redirect)
        should_redirect_to("uniform") { uniform_path(assigns(:uniform)) }

        should_set_the_flash(:success)
      end       
      
      context "requesting DELETE :destroy without associations" do
        setup do
          delete :destroy, :id => @uniform.id
        end
        
        should_redirect_to("uniforms list") { uniforms_path }
        
        should_change("number of uniforms", :by => -1) { Uniform.count }
        should_set_the_flash(:success)
      end
      
      context "requesting DELETE :destroy with associations" do
        setup do
          Uniform.any_instance.stubs(:destroy).returns(false)
          # because there is no stub_chain for any_instance in mocha
          Uniform.any_instance.stubs(:errors).returns(mock(:full_messages => ["erreur"]))
          delete :destroy, :id => @uniform.id
        end
        
        should_redirect_to("uniform") { uniform_path(assigns(:uniform)) }
        
        should_not_change("number of uniform") { Uniform.count }
        should_set_the_flash(:error)
      end
    end
  end
end
