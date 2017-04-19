require_relative "./my_nav_module"
require("bundler/setup")
Bundler.require(:default)
Dir[File.dirname(__FILE__) + '/lib/*.rb'].each { |file| require file }
also_reload("lib/*.rb")

helpers MyNavModule

configure do
  enable :sessions unless test?
  set :session_secret, "jesus"
end

# landing
get('/') do
  erb(:index)
end

# sign up form for log in
get '/signup' do
  erb :'/signup'
end

# after signup
post ('/signup') do
  @user = User.create(:name => params[:name], :email => params[:email], :password => params[:password])
  if @user.valid?
    @signup_success = true
    redirect "/login"
  else
    erb (:signup_error)
  end
end


get '/login' do
  erb (:login)
end

post "/login" do
  user = User.find_by(:email => params[:email])
  if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect "/main"
  else
      erb (:login_error)
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

# the main page where search and list of all bookmark are shown
get('/main') do
  @articles = Article.all
  @tags = Tag.all
  @user = User.find(session[:user_id])
  @nav = nav_function (request)
  erb(:main)
end

#search method
get('/search') do
  @articles = Article.all
  if params[:search]
    @articles = Article.search(params[:search])
  else
    @articles = Article.all
  end
  erb(:results)
end

#access tag from the nav bar
get('/tags/:id') do
  erb(:tag)
end

#after enter the book mark
post('/articles') do
  @article = Article.create({:title => params.fetch('title'), :link => params.fetch('link'), :shared_by => params.fetch('shared_by')})
  tag_ids = params.fetch('tag_ids', nil)
  tag_create = params.fetch('tag_create', nil)
  if tag_ids != nil and tag_ids.length > 0
    tag_ids.each do |tag_id|
      ArticlesTag.create({:article_id => @article.id, :tag_id => tag_id})
    end
  end
  if tag_create != nil
    @new_tag = Tag.create({:name => tag_create})
    ArticlesTag.create({:article_id => @article.id, :tag_id => @new_tag.id})
  end

  if !@article.valid? or !@new_tag.valid?
    erb(:add_article_error)
  else
    redirect to ('/main')
  end
end

# access favorite from the nav bar
get('/favorites/:id') do
  erb(:favorite)
end

post("/articles") do
  title = params.fetch("title")
  article = Article.new({:title => title, :link => "placeholder", :shared_by => "placeholder", :like => 0, :id => nil})
  article.save()
  redirect("/")
end
