require 'spec_helper'

describe ContactController do
  describe "POST 'create'" do
    context "when valid" do
      before(:each) do
        post :create, message: { name: 'Chris Moore', email: 'chris@cdmwebs.com', project: 'This is the body', human: 'yes' }
      end

      it { should respond_with(:redirect) }
      it { should set_the_flash }
    end

    context "when invalid" do
      before(:each) do
        post :create, message: { name: 'Chris' }
      end

      it { should respond_with(:success) }
      it { should render_template('pages/contact') }
      it { should_not render_with_layout }
      it { should_not set_the_flash }
    end
  end
end
