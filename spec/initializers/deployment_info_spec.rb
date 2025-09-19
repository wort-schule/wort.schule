# frozen_string_literal: true

require "rails_helper"

RSpec.describe DeploymentInfo do
  describe ".timestamp" do
    context "when DEPLOY_TIMESTAMP file exists" do
      let(:timestamp) { "2025-01-19T14:30:00+0000" }

      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(Rails.root.join("DEPLOY_TIMESTAMP")).and_return(true)
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with(Rails.root.join("DEPLOY_TIMESTAMP")).and_return(timestamp)
        described_class.instance_variable_set(:@timestamp, nil) # Reset memoization
      end

      it "returns the timestamp from the file" do
        expect(described_class.timestamp).to eq(timestamp)
      end
    end

    context "when DEPLOY_TIMESTAMP file does not exist" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(Rails.root.join("DEPLOY_TIMESTAMP")).and_return(false)
        described_class.instance_variable_set(:@timestamp, nil) # Reset memoization
      end

      it "returns nil" do
        expect(described_class.timestamp).to be_nil
      end
    end
  end

  describe ".git_revision" do
    context "when REVISION file exists" do
      let(:revision) { "169b1ad0881334f9b232b579db66b53062c8f7c5" }

      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(Rails.root.join("REVISION")).and_return(true)
        allow(File).to receive(:read).and_call_original
        allow(File).to receive(:read).with(Rails.root.join("REVISION")).and_return(revision)
        described_class.instance_variable_set(:@git_revision, nil) # Reset memoization
      end

      it "returns the revision from the file" do
        expect(described_class.git_revision).to eq(revision)
      end
    end

    context "when REVISION file does not exist" do
      before do
        allow(File).to receive(:exist?).and_call_original
        allow(File).to receive(:exist?).with(Rails.root.join("REVISION")).and_return(false)
        described_class.instance_variable_set(:@git_revision, nil) # Reset memoization
      end

      it "returns nil" do
        expect(described_class.git_revision).to be_nil
      end
    end
  end

  describe ".deployed_at" do
    context "when timestamp exists and is valid" do
      let(:timestamp) { "2025-01-19T14:30:00+0000" }

      before do
        allow(described_class).to receive(:timestamp).and_return(timestamp)
      end

      it "returns a Time object in Berlin timezone" do
        deployed_at = described_class.deployed_at
        expect(deployed_at).to be_a(ActiveSupport::TimeWithZone)
        expect(deployed_at.zone).to eq("CET")
      end
    end

    context "when timestamp does not exist" do
      before do
        allow(described_class).to receive(:timestamp).and_return(nil)
      end

      it "returns nil" do
        expect(described_class.deployed_at).to be_nil
      end
    end

    context "when timestamp is invalid" do
      before do
        allow(described_class).to receive(:timestamp).and_return("invalid-timestamp")
      end

      it "returns nil" do
        expect(described_class.deployed_at).to be_nil
      end
    end
  end

  describe ".short_revision" do
    context "when git_revision exists" do
      let(:revision) { "169b1ad0881334f9b232b579db66b53062c8f7c5" }

      before do
        allow(described_class).to receive(:git_revision).and_return(revision)
      end

      it "returns the first 7 characters" do
        expect(described_class.short_revision).to eq("169b1ad")
      end
    end

    context "when git_revision does not exist" do
      before do
        allow(described_class).to receive(:git_revision).and_return(nil)
      end

      it "returns nil" do
        expect(described_class.short_revision).to be_nil
      end
    end
  end
end
