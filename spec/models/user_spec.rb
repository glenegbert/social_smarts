RSpec.describe User, type: :model do
  before do
    @user = create(:user)
  end

  it "has updateable auth attrs" do
    @user.update_auth_attrs(new_auth)

    expect(@user.provider).to eq "github"
    expect(@user.uid).to eq "1234"
    expect(@user.name).to eq "lukeaiken"
    expect(@user.oauth_token).to eq "new token"
    expect(@user.oauth_secret).to eq "new secret"
  end

  it "has a Klout score" do
    VCR.use_cassette('user_klout') do
      expect(User.klout_score(@user.uid)).to be_a Integer
    end
  end

  private

  def new_auth
    OpenStruct.new(
      provider: "github",
      uid: "1234",
      info: OpenStruct.new(
        name: "lukeaiken"),
      credentials: OpenStruct.new(
        token: "new token",
        secret: "new secret"))
  end
end
