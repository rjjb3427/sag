require 'spec_helper'

describe "URL Rewriting" do
  context "route not found" do
    it "returns a 404 and shows the landing page" do
      get 'http://gaslight.co/foo-bar'
      response.response_code.should == 404
    end
  end

  context "old blogs" do
    context 'blog.gaslight.co' do
      let(:host) { 'blog.gaslight.co' }

      it "redirects unknown posts to /blog" do
        get "http://#{host}/post/i-made-this-up"
        response.response_code.should == 301
        response.location.should eq('http://gaslight.co/blog')
      end

      it "rewrites root requests to the new blog" do
        get "http://#{host}"
        response.response_code.should == 301
        response.location.should eq('http://gaslight.co/blog')
      end

      it "rewrites old blog article requests to the new blog" do
        get "http://#{host}/post/50698505607"
        response.response_code.should == 301
        response.location.should eq('http://gaslight.co/blog/qcmerge-chris-glass')
      end

      it 'redirects old tumblr posts to the new blog' do
        get "http://#{host}/post/54512786990/intermediate-ember-controller-concepts"
        response.response_code.should == 301
        response.location.should eq('http://gaslight.co/blog/intermediate-ember-controller-concepts')
      end

      it 'redirects old tumblr posts with params to the new blog' do
        get "http://#{host}/post/54512786990?utm_source=feedburner&utm_medium=feed&utm_campaign=Feed%3A+GaslightSoftwareBlog+%28Gaslight+Blog%29"
        response.response_code.should == 301
        response.location.should eq('http://gaslight.co/blog/intermediate-ember-controller-concepts')
      end
    end

    context 'blog.gaslightsoftware.com' do
      let(:host) { 'blog.gaslightsoftware.com' }

      it "rewrites old blog root requests to the new blog" do
        get "http://#{host}"
        response.response_code.should == 301
        response.location.should eq('http://gaslight.co/blog')

        get "http://#{host}/"
        response.response_code.should == 301
        response.location.should eq('http://gaslight.co/blog')
      end

      it "rewrites old blog article requests to the new blog" do
        get "http://#{host}/post/50698505607"
        response.response_code.should == 301
        response.location.should eq('http://gaslight.co/blog/qcmerge-chris-glass')
      end

      it 'redirects old tumblr posts to the new blog' do
        get "http://#{host}/post/54512786990/intermediate-ember-controller-concepts"
        response.response_code.should == 301
        response.location.should eq('http://gaslight.co/blog/intermediate-ember-controller-concepts')
      end
    end
  end

  context "coffee.gaslightsoftware.com" do
    it "rewrites old coffee requests to the new page" do
      get 'http://coffee.gaslightsoftware.com'
      response.response_code.should == 301
      response.location.should == 'http://gaslight.co/coffee'
    end
  end

  context "training.gaslightsoftware.com" do
    it "rewrites old training requests to the new subdomain" do
      get 'http://training.gaslightsoftware.com/workshop/12345'
      response.response_code.should == 301
      response.location.should match('training.gaslight.co')
    end
  end

  context "gaslightsoftware.com" do
    it "redirects old site requests to the new site" do
      get 'http://gaslightsoftware.com/post/12345'
      response.response_code.should == 301
      response.location.should == 'http://gaslight.co/post/12345'
    end

    it "redirects the www subdomain to gaslight.co" do
      get 'http://www.gaslightsoftware.com/something'
      response.response_code.should == 301
      response.location.should == 'http://gaslight.co/something'
    end
  end

  # CDM: I totally botched this setting it up and want to prevent it
  # from happening in the future.
  it "doesn't redirect requests to gaslight.co to blog.gaslight.co" do
    get 'http://gaslight.co/'
    response.should be_redirect
    response.location.should == 'http://gaslight.co/home'
  end

  context "local development" do
    it "doesn't redirect requests to gaslight.dev to gaslight.co" do
      get 'http://gaslight.dev/'
      response.should be_redirect
      response.location.should == 'http://gaslight.dev/home'
    end

    it "doesn't redirect requests to localhost:3000 to gaslight.co" do
      get 'http://localhost:3000/'
      response.should be_redirect
      response.location.should match(%r|http://localhost:3000/home|)
    end
  end
end
