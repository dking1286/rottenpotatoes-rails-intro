class MoviesController < ApplicationController

  def movie_params
    params.require(:movie).permit(:title, :rating, :description, :release_date)
  end

  def show
    id = params[:id] # retrieve movie ID from URI route
    @movie = Movie.find(id) # look up movie by unique ID
    # will render app/views/movies/show.<extension> by default
  end

  def index
    # Initialize session[] if it does not already have values
    session[:checked_ratings] ||= Movie.all_ratings
    session[:sort_by] ||= 'none'
    
    # Store parameters in session hash if parameters were given
    session[:sort_by] = params[:sort_by] unless params[:sort_by].nil?
    session[:checked_ratings] = params[:ratings].keys unless params[:ratings].nil?
    
    # if either of the parameters were missing,
    # redirect to the URI with the parameters filled in according to session[]
    if !(params[:sort_by] && params[:ratings])
      checked_ratings_hash = {}
      session[:checked_ratings].each do |checked_rating|
        checked_ratings_hash[checked_rating] = '1'
      end
      flash.keep
      redirect_to movies_path(
        :sort_by => session[:sort_by], :ratings => checked_ratings_hash
      )
    end
    
    # Set instance variables for the view
    @movies = Movie.where(:rating => session[:checked_ratings])
    if session[:sort_by] == 'title' || session[:sort_by] == 'release_date'
      @movies = @movies.order(session[:sort_by])
    end
    @all_ratings = Movie.all_ratings
  end

  def new
    # default: render 'new' template
  end

  def create
    @movie = Movie.create!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully created."
    redirect_to movies_path
  end

  def edit
    @movie = Movie.find params[:id]
  end

  def update
    @movie = Movie.find params[:id]
    @movie.update_attributes!(movie_params)
    flash[:notice] = "#{@movie.title} was successfully updated."
    redirect_to movie_path(@movie)
  end

  def destroy
    @movie = Movie.find(params[:id])
    @movie.destroy
    flash[:notice] = "Movie '#{@movie.title}' deleted."
    redirect_to movies_path
  end

end
