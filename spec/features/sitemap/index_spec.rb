require 'spec_helper'

feature 'Sitemap' do
  scenario 'Index' do
    visit '/sitemap.xml'
    page.should have_content('contact')
  end
end

