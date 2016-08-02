require 'rails_helper'

describe UniformsController do

  setup(:activate_authlogic)

  context "an user logged in" do

    before(:each) do
      login
    end

    let(:uniform) { create(:uniform, :station => @station) }

    describe "GET :index" do

      before(:each) do
        get :index
      end

      it { should respond_with(:success) }
      it { should render_template("index")  }
      it { should render_with_layout("back") }

      it { expect(assigns(:uniforms)).to_not be_nil}
    end

    describe "GET :show for a non existing uniform" do

      before(:each) do
        get :show, :params => { :id => -1 }
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(uniforms_path) }

      it { should set_flash[:error] }
    end

    describe "GET :new" do

      before(:each) do
        get :new
      end

      it { should respond_with(:success) }
      it { should render_template("new") }
      it { should render_with_layout("back") }
    end

    describe "POST :create with bad data" do

      before(:each) do
        post :create, :params => { :uniform => {:title => '', :code => '2b', :description => 'test'} }
      end

      it { should respond_with(:success) }
      it { should render_template("new") }
      it { should render_with_layout("back") }
    end

    describe "POST :create with good data" do

      before(:each) do
        post :create, :params => { :uniform => attributes_for(:uniform) }
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(uniform_path(assigns(:uniform))) }

      it { expect(assigns(:uniform)).to_not be_nil}
      it { should set_flash[:success] }
    end

    describe "POST :reset" do

      before(:each) do
        post :reset
      end

      it { should respond_with(:redirect) }

      it { should set_flash[:success] }
    end

    describe "GET :show on existing uniform" do

      before(:each) do
        get :show, :params => { :id => uniform.id }
      end

      it { should respond_with(:success) }
      it { should render_template("show") }
      it { should render_with_layout("back") }
    end

    describe "GET :edit" do

      before(:each) do
        get :edit, :params => { :id => uniform.id }
      end

      it { should respond_with(:success) }
      it { should render_template("edit") }
      it { should render_with_layout("back") }
    end

    describe "PATCH :update with bad data" do

      before(:each) do
        patch :update, :params => { :id => uniform.id, :uniform => {:title => '', :code => '2b', :description => 'test'} }
      end

      it { should respond_with(:success) }
      it { should render_template("edit") }
      it { should render_with_layout("back") }
    end

    describe "PATCH :update with good data" do

      before(:each) do
        patch :update, :params => { :id => uniform.id, :uniform => attributes_for(:uniform) }
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(uniform_path(assigns(:uniform))) }

      it { should set_flash[:success] }
    end

    describe "DELETE :destroy without association" do

      before(:each) do
        delete :destroy, :params => { :id => uniform.id }
      end

      it { should redirect_to(uniforms_path) }

      it { should set_flash[:success] }
    end

    describe "DELETE :destroy with associations" do

      before(:each) do
        allow_any_instance_of(Uniform).to receive(:convocations).and_return(double(:empty? => false))

        delete :destroy, :params => { :id => uniform.id }
      end

      it { should redirect_to(uniform_path(assigns(:uniform))) }

      it { should set_flash[:error] }
    end
  end
end
