require "rails_helper"

RSpec.describe Feature do
  describe "use_wk_api" do
    before { allow(Feature).to receive(:active_features).and_return(features) }

    context "when activated" do
      let(:features) { [:use_wk_api] }
      it "reports true" do
        expect(Feature.active?(:use_wk_api)).to be true
      end
    end

    context "when deactivated" do
      let(:features) { [] }
      it "reports false" do
        expect(Feature.active?(:use_wk_api)).to be false
      end
    end
  end
end
