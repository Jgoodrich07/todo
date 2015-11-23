require "spec_helper"


describe "Sinatra Todo Application" do


  after do
    List.all.destroy
    Task.all.destroy
    User.all.destroy
  end

  context "GET /" do
    it "should load the home page" do
      get "/"

      expect(last_response).to be_ok
    end
  end

  context "POST /sign_up"
    it "should sign up a new user" do
      post "/sign_up", {:user => {name: "J", password: "12341234"}}

      expect(last_response.status).to be(302)
    end
  end

  context "POST /sign_in" do
    it "should sign in an existing user" do
      User.create(name: "Jerome", password: "12341234")
      post "/sign_in", {:user => {name: "Jerome", password: "12341234"}}

      expect(last_response.status).to eq(302)
    end

    it "shouldn't sign in a user that doesn't exist" do
      post "/sign_in", {:user => {name: "Jerome", password: "12341234"}}

      expect(last_response.status).to eq(200)
    end
  end

  context "GET /user/:user_id" do
    xit "loads the page if the user is the session's current user" do
      user = User.create(id: "1", name: "Jerome", password: "12341234")
      List.create(id: "1", name: "New List", user_id: "1")
      get "/user/1", {}, {'rack.session' => {current_user: "1"} }

      expect(last_response.body).to eq("New List")
    end

    it "redirects to session[:current_user]'s index when accesing an unauthorized page" do
      User.create(id: "1", name: "Jerome", password: "12341234")
      User.create(id: "2", name: "Sol", password: "12341234")
      get "/user/1", {}, {'rack.session' => {current_user: "2"} }

      expect(last_response.redirect?).to eq(true)
      follow_redirect!
      expect(last_request.path).to eq("/user/2")
    end
  end

  context "POST /new/list" do
    it "should display a newly created list" do
      post "/new/list", {list: "New List"}

      expect(last_response.body).to include("New List")
    end
  end

  context "GET /list/:list_id" do
    xit "should show a list to the appropriate user" do
      list = List.create(name: "New List", user_id: "1")
      get "/list/1", {}, {"rack.session" => {current_user: "1"}}

      expect(last_response.body).to include("New List")
    end

    it "shouldn't show a list to an unauthorized user" do
      list = List.create(name: "New List", user_id: "2")
      get "/list/1", {}, {"rack.session" => {current_user: "1"}}

      expect(last_response.status).to eq(302)
    end
  end

  context "POST list/:list_id/new/task" do
    xit "should display a newly created task" do
      User.create(id: "1", name: "Jerome", password: "12341234")
      List.create(name: "New List", user_id: "1")
      post '/list/1/new/task', {task: "New Task"}
      get '/list/1', {}, {"rack.session" => {current_user: "1"}}

      expect(last_response.body).to include("New Task")
    end
  end

  context "GET /logout" do
    it "ends a session" do
      get "/logout", {}, {"rack.session" => {current_user: "1"}}

      expect(rack_mock_session.cookie_jar[:current_user]).to eq(nil)
    end
  end
end
