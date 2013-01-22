require 'test_helper'

class OAuthTest < Test::Unit::TestCase
  
  def setup
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:twitter] = OmniAuth::AuthHash.new({
      :provider => 'twitter',
      :uid => '12345',
      :info => {
        :email => 'user@twitter.com'
      }
    })
    
    OmniAuth.config.mock_auth[:twitter_second] = OmniAuth::AuthHash.new({
      :provider => 'twitter',
      :uid => '12312345',
      :info => {
        :email => 'uniqueuser@twitter.com'
      }
    })
    
    OmniAuth.config.mock_auth[:twitter_third] = OmniAuth::AuthHash.new({
      :provider => 'twitter',
      :uid => '32145',
      :info => {
        :email => 'alice_bob@twitter.com'
      }
    })
    
    
    OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
      :provider => 'facebook',
      :uid => '23456',
      :info => {
        :email => 'user@fb.com'
      }
    })
    
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
      :provider => 'github',
      :uid => '34567',
      :info => {
        :email => 'user@github.com',
        :nickname => 'test_github_user'
      }
    })
    
  end
  
  def test_auth_facebook_existing
    name = 'alice bob'
    mail = 'alice.bob@example.com'
    
    oauth = OmniAuth.config.mock_auth[:facebook]
    person = FactoryGirl.create(:person, full_name: name, email: mail)
    person.add_omniauth_properties(oauth)
    
    assert_equal '23456', person.facebook_uid
    assert_equal mail, person.email
    assert_equal name, person.full_name
  end
  
  
  def test_auth_github_existing
    name = 'alice bob'
    mail = 'alice.bob@example.com'
    
    oauth = OmniAuth.config.mock_auth[:github]
    person = FactoryGirl.create(:person, full_name: name, email: mail)
    person.add_omniauth_properties(oauth)
    
    assert_equal '34567', person.github_uid
    assert_equal 'test_github_user', person.github_nickname
    assert_equal mail, person.email
    assert_equal name, person.full_name
  end
  
  
  def test_auth_twitter_existing
    name = 'alice bob'
    mail = 'alice.bob@example.com'
    
    oauth = OmniAuth.config.mock_auth[:twitter]
    person = FactoryGirl.create(:person, full_name: name, email: mail)
    person.add_omniauth_properties(oauth)
    
    assert_equal '12345', person.twitter_uid
    assert_equal mail, person.email
    assert_equal name, person.full_name
  end
  
  def test_auth_cumulative_existing
    name = 'alice bob'
    mail = 'alice.bob@example.com'
    person = FactoryGirl.create(:person, full_name: name, email: mail)
    
    oauth = OmniAuth.config.mock_auth[:facebook]
    person.add_omniauth_properties(oauth)
    
    oauth = OmniAuth.config.mock_auth[:github]
    person.add_omniauth_properties(oauth)
    
    oauth = OmniAuth.config.mock_auth[:twitter]
    person.add_omniauth_properties(oauth)
    
    assert_equal '23456', person.facebook_uid
    assert_equal 'test_github_user', person.github_nickname
    assert_equal '34567', person.github_uid
    assert_equal '12345', person.twitter_uid
    assert_equal mail, person.email
    assert_equal name, person.full_name
  end
   
  
  def test_auth_cumulative_first_time
    oauth = OmniAuth.config.mock_auth[:twitter_second]
    person = Person.from_omniauth(oauth)
    
    assert_equal '12312345', person.twitter_uid
    assert_equal 'uniqueuser@twitter.com', person.email
  end
  
  
  def test_auth_cumulative_on_existing_assuming_first_time
    name = 'alice bob'
    mail = 'alice_bob@twitter.com'
    person = FactoryGirl.create(:person, full_name: name, email: mail)
    
    oauth = OmniAuth.config.mock_auth[:twitter_third]
    person2 = Person.from_omniauth(oauth)
     
    assert_equal '32145', person2.twitter_uid  
    assert_equal person, person2
  end
  
end