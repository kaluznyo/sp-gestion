require 'rails_helper'

describe ItemPhotoUploader do
  include CarrierWave::Test::Matchers

  let(:uploader) do
    uploader = ItemPhotoUploader.new(create(:item), :item_photo)
    uploader.store!(File.open("#{Rails.root}/spec/fixtures/files/uploads/logo/logo_test.png"))
    uploader
  end

  let(:uploader_empty) do
    ItemPhotoUploader.new(create(:item), :item_photo)
  end

  context 'filename' do
    it "should be item" do
      expect(uploader.filename).to eq "item.png"
    end
  end

  context 'resize' do
    it "should scale down to 480,360 pixels" do
      expect(uploader).to have_dimensions(480, 360)
    end
  end

  context 'default_url' do
    it "should be default_photo_480_360.png" do
      expect(uploader_empty.url).to match /\/assets\/back\/default_photo_480_360-.*\.png/
    end
  end
end
