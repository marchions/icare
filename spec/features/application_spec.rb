require 'spec_helper'

describe 'Application' do
  it "protects pages from guest users" do
    visit '/dashboard'
    expect(page).to have_content I18n.t('flash.errors.not_authenticated')
  end

  it "redirects banned users to the banned page" do
    banned_user = FactoryGirl.create :user, banned: true, uid: '123456'
    visit '/auth/facebook'
    expect(current_path).to eq banned_path
    [itineraries_path, new_itinerary_path].each do |path|
      visit path
      expect(current_path).to eq banned_path
    end
  end

  describe 'Locale' do
    it "fallbacks to en-US when user is passing an unknown locale param" do
      user = FactoryGirl.create :user, uid: '123456'
      visit '/auth/facebook'
      visit itineraries_user_path(user, locale: 'XX-ZZ')
      expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
    end

    it "fallbacks to en-US when user is passing a compatible locale param" do
      user = FactoryGirl.create :user, uid: '123456'
      visit '/auth/facebook'
      visit itineraries_user_path(user, locale: 'en-XX')
      expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
    end

    it "fallbacks to en-US when user is coming from facebook with a compatible locale" do
      user = FactoryGirl.create :user, uid: '123456', locale: 'en-YY'
      visit '/auth/facebook'
      visit itineraries_user_path(user)
      expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
    end

    it "fallbacks to en-US when user is using en locale" do
      user = FactoryGirl.create :user, uid: '123456', locale: 'en-GB'
      visit '/auth/facebook'
      visit itineraries_user_path(user, locale: 'en')
      expect(page).to have_content I18n.t('users.itineraries.title', locale: 'en-US')
    end
  end
end
