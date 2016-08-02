require 'rails_helper'

describe DaybooksController do

  setup(:activate_authlogic)

  describe "an user logged in" do
    before(:each) do
      login
    end

    let(:daybook) { create(:daybook, :station => @station) }

    describe "GET :index" do

      before(:each) do
        get :index
      end

      it { should respond_with(:success) }
      it { should render_template("index") }
      it { should render_with_layout("back") }

      it { expect(assigns(:daybooks)).to_not be_nil}
    end

    describe "GET :show for a non existing daybook" do

      before(:each) do
        get :show, :params => { :id => -1 }
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(daybooks_path) }

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
        post :create, :params => { :daybook => {:text => ''} }
      end

      it { should respond_with(:success) }
      it { should render_template("new") }
      it { should render_with_layout("back") }
    end

    describe "POST :create with good data" do

      before(:each) do
        post :create, :params => { :daybook => attributes_for(:daybook) }
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(daybook_path(assigns(:daybook))) }

      it { expect(assigns(:daybook)).to_not be_nil}
      it { should set_flash[:success] }
    end

    describe "GET :show on existing daybook" do

      before(:each) do
        get :show, :params => { :id => daybook.id }
      end

      it { should respond_with(:success) }
      it { should render_template("show") }
      it { should render_with_layout("back") }
    end

    describe "GET :edit" do

      before(:each) do
        get :edit, :params => { :id => daybook.id }
      end

      it { should respond_with(:success) }
      it { should render_template("edit") }
      it { should render_with_layout("back") }
    end

    describe "PATCH :update with bad data" do

      before(:each) do
        patch :update, :params => { :id => daybook.id, :daybook => {:text => ''} }
      end

      it { should respond_with(:success) }
      it { should render_template("edit") }
      it { should render_with_layout("back") }
    end

    describe "PATCH :update with good data" do

      before(:each) do
        patch :update, :params => { :id => daybook.id, :daybook => attributes_for(:daybook) }
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(daybook_path(assigns(:daybook))) }

      it { should set_flash[:success] }
    end

    describe "DELETE :destroy" do

      before(:each) do
        delete :destroy, :params => { :id => daybook.id }
      end

      it { should redirect_to(daybooks_path) }

      it { should set_flash[:success] }
    end
  end
end
