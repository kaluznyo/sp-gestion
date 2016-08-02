require 'rails_helper'

describe TrainingsController do

  setup(:activate_authlogic)

  context "an user logged in" do

    before(:each) do
      login
    end

    let(:training) { create(:training, :station => @station) }

    describe "GET :index" do

      before(:each) do
        get :index
      end

      it { should respond_with(:success) }
      it { should render_template("index") }
      it { should render_with_layout("back") }

      it { expect(assigns(:trainings)).to_not be_nil}
    end

    describe "GET :show for a non existing training" do

      before(:each) do
        get :show, :params => { :id => -1 }
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(trainings_path) }

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
        post :create, :params => { :training => {:name => '', :short_name => 'test'} }
      end

      it { should respond_with(:success) }
      it { should render_template("new") }
      it { should render_with_layout("back") }
    end

    describe "POST :create with good data" do

      before(:each) do
        post :create, :params => { :training => attributes_for(:training) }
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(training_path(assigns(:training))) }

      it { expect(assigns(:training)).to_not be_nil}
      it { should set_flash[:success] }
    end

    describe "GET :show on existing training" do

      before(:each) do
        get :show, :params => { :id => training.id }
      end

      it { should respond_with(:success) }
      it { should render_template("show") }
      it { should render_with_layout("back") }
    end

    describe "GET :edit" do

      before(:each) do
        get :edit, :params => { :id => training.id }
      end

      it { should respond_with(:success) }
      it { should render_template("edit") }
      it { should render_with_layout("back") }
    end

    describe "PATCH :update with bad data" do

      before(:each) do
        patch :update, :params => { :id => training.id, :training => {:name => '', :short_name => 'test'} }
      end

      it { should respond_with(:success) }
      it { should render_template("edit") }
      it { should render_with_layout("back") }
    end

    describe "PATCH :update with good data" do

      before(:each) do
        patch :update, :params => { :id => training.id, :training => attributes_for(:training) }
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(training_path(assigns(:training))) }

      it { should set_flash[:success] }
    end


    describe "DELETE :destroy without association" do

      before(:each) do
        delete :destroy, :params => { :id => training.id }
      end

      it { should redirect_to(trainings_path) }

      it { should set_flash[:success] }
    end

    describe "DELETE :destroy with associations" do

      before(:each) do
        allow_any_instance_of(Training).to receive(:firemen).and_return(double(:empty? => false))

        delete :destroy, :params => { :id => training.id }
      end

      it { should redirect_to(training_path(assigns(:training))) }

      it { should set_flash[:error] }
    end
  end
end
