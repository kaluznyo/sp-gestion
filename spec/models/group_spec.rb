require 'rails_helper'

describe Group do

  it { should belong_to(:station) }
  it { should have_many(:users) }
  it { should have_many(:permissions) }
  it { should have_many(:resources) }

  it { should validate_presence_of(:name).with_message(/nom/) }

  describe "#initialized_permissions" do

    subject { group.initialized_permissions(resources) }

    let(:resources) { [create(:resource_checklist)] }

    context "with a new group" do

      let(:group) { create(:group) }

      it "should have one item" do
        expect(subject.size).to eq 1
      end
    end

    context "with an existing group" do

      let(:group) { create(:group, :permissions => [create(:permission,
                                                    :resource => resources.first)]) }

      it "should have one item" do
        expect(subject.size).to eq 1
      end

      it "should be linked to the existing resource" do
        expect(resources.first).to eq group.permissions.first.resource
      end
    end
  end
end
