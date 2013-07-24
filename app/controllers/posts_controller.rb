require 'rewrite'

class PostsController < ApplicationController

  respond_to :html, :rss, :json

  expose(:posts) { Post.published.by_publish_date }
  expose(:post) { Post.published.find_by_slug(params[:slug] || params[:id]) }
  expose(:popular_tags) { Post.tag_counts.order('count desc').limit(20) }
  expose(:authors) { Post.authors }
  expose(:author) { Author.find_by_tumblr(params[:author]) }

  def index
    self.posts = self.posts.written_by([params[:author]]) if params[:author]
    self.posts = self.posts.tagged_with([params[:tagged]]) if params[:tagged]
    self.posts = self.posts.page(params[:page]).per(items_per_page)
    respond_with posts
  end

  def for_date
    self.posts = Post.posted_on(params[:year], params[:month], params[:day])
    @total = Post.published.count
    respond_with self.posts
  end

  def archive
    self.posts = posts.group_by { |post| post.published_at.beginning_of_month }
    @total = Post.published.count
    respond_with self.posts
  end

  def search
    self.posts = Post.search(params[:q])
    respond_with posts, template: 'posts/index'
  end

  def old
    new_host = Rails.env.development? ? 'gaslight.dev' : 'gaslight.co'
    new_slug = Rewrite.new_post_url(request.fullpath)
    new_url = new_slug ? post_url(new_slug, host: new_host) : posts_url(host: new_host)
    redirect_to new_url, status: 301
  end

  def podcast_iframe
    respond_with post, layout: false
  end

  protected

  def search_date
    year = (params[:year] || Date.today.year).to_i
    month = (params[:month] || Date.today.month).to_i
    day = (params[:day] || Date.today.day).to_i
    Date.new(year, month, day)
  end
  helper_method :search_date

  def items_per_page
    return 15 if request.format == 'rss'
    index? ? 3 : 100
  end

  def index?
    actions = %w(q tagged author year)
    (params.keys & actions).none?
  end
end

