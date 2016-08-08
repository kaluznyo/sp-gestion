require 'rails_helper'

describe PasswordResetsController do

  context "a station in demo mode" do

    let(:station) { create(:station, :demo => true) }

    before(:each) do
      @request.host = "#{station.url}.test.local"
    end

    describe "GET :new" do

      before(:each) do
        get :new
      end

      it { should redirect_to(login_path) }

      it { should set_flash[:error] }
    end
  end

  context "a station subdomain with a user" do

    let(:station) { create(:station) }

    let(:user) { create(:user_confirmed, :station => station) }

    before(:each) do
      @request.host = "#{station.url}.test.local"
    end

    describe "GET :new" do

      before(:each) do
        get :new
      end

      it { should respond_with(:success) }
      it { should render_template("new") }
      it { should render_with_layout("login") }
    end

    describe "POST :create with bad data" do

      before(:each) do
        expect_any_instance_of(UserMailer).to_not receive(:password_reset_instructions)

        post :create, :params => { :email => 'test@test.com' }
      end

      it { should respond_with(:success) }
      it { should render_template("new") }
      it { should render_with_layout("login") }

      it { should set_flash.now[:error] }
    end

    describe "POST :create with good data" do

      before(:each) do
        expect_any_instance_of(UserMailer).to receive(:password_reset_instructions)

        post :create, :params => { :email => user.email }
      end

      it { should respond_with(:success) }
      it { should render_template("new") }
      it { should render_with_layout("login") }

      it { should set_flash.now[:warning] }
    end

    describe "GET :edit with bad data" do

      before(:each) do
        get :edit, :params => { :id => -1 }
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(login_path) }

      it { should set_flash[:error] }
    end

    describe "GET :edit with good data" do

      before(:each) do
        get :edit, :params => { :id => user.perishable_token }
      end

      it { should respond_with(:success) }
      it { should render_template("edit") }
      it { should render_with_layout("login") }

      it { should_not set_flash() }
    end

    describe "PATCH :update with bad data" do

      before(:each) do
        patch :update, :params => { :id => user.perishable_token,
                     :user => {:password => 'test',
                               :password_confirmation => 'tes'} }
      end

      it { should respond_with(:success) }
      it { should render_template("edit") }
      it { should render_with_layout("login") }
    end

    describe "PATCH :update with good data" do

      before(:each) do
        patch :update, :params => { :id => user.perishable_token,
                     :user => {:password => 'test2958',
                               :password_confirmation => 'test2958'} }
      end

      it { should respond_with(:redirect) }
      it { should redirect_to(root_back_path) }

      it { should be_logged_in }
    end
  end
end
