require File.dirname(__FILE__) + '/../../spec_helper'

describe RegulationsDotGov::CommentForm do
  let(:client) { double(:client) }

  describe "#allow_attachments?" do
    it "returns true if attachments are allowed" do
      allow_attachments = true
      comment_form = RegulationsDotGov::CommentForm.new(client, {'showAttachment' => allow_attachments})
      
      expect( comment_form.allow_attachments? ).to eq(allow_attachments)
    end

    it "returns false if attachments are not allowed" do
      allow_attachments = false
      comment_form = RegulationsDotGov::CommentForm.new(client, {'showAttachment' => allow_attachments})
      
      expect( comment_form.allow_attachments? ).to eq(allow_attachments)
    end
  end
end
