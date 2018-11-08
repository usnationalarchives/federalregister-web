require File.dirname(__FILE__) + '/../spec_helper'

describe EntryEmail do
  describe "validations" do
    it "has a valid factory" do
      expect(
        build(:entry_email).valid?
      ).to be(true)
    end

    it "requires a remote_ip" do
      expect(
        build(:entry_email, remote_ip: nil).valid?
      ).to be(false)
    end

    it "requires a sender" do
      expect(
        build(:entry_email, sender: nil).valid?
      ).to be(false)
    end

    it "requires recipients" do
      expect(
        build(:entry_email, recipients: nil).valid?
      ).to be(false)
    end

    it "requires a document_number" do
      expect(
        build(:entry_email, document_number: nil).valid?
      ).to be(false)
    end
  end

  before(:each) do
    EntryEmail.any_instance.stub(:deliver_email)
  end

  describe '#sender=' do
    it "hashes the sender email address consistently" do
      email_1 = build(:entry_email, sender_hash: nil)
      email_1.sender = 'john.doe@example.com'
      email_1.save!

      email_2 = build(:entry_email, sender_hash: nil)
      email_2.sender = 'john.doe@example.com'
      email_2.save!

      expect(email_1.sender_hash).to eq(email_2.sender_hash)
    end

    it "adds an error if sender is not a valid email address" do
      email = build(:entry_email, sender: "NOT-A-VALID-EMAIL-ADDRESS")

      email.valid?
      expect(email.errors[:sender].size).to eq(1)
    end

    it "accepts valid sender emails" do
      email = build(:entry_email, :sender => "john@example.com")

      email.valid?
      expect(email.errors[:sender].size).to eq(0)
    end
  end

  it "sends an email after the record is created" do
    EntryEmail.any_instance.unstub(:deliver_email)
    email = build(:entry_email)

    expect(DocumentMailer).to receive(:email_a_friend).
      with(email).and_call_original #don't just return nil and call #deliver on it

    email.save!
  end

  describe '#recipients=' do
    let(:email) { build(:entry_email) }

    it "stores the provided array unchanged if given an array" do
      email.recipients = ["john@example.com","jane@example.com"]

      expect(email.recipient_emails).to eq ["john@example.com", "jane@example.com"]
    end

    it "splits a string into an array" do
      email.recipients = "john@example.com, jane@example.com"

      expect(email.recipient_emails).to eq ["john@example.com", "jane@example.com"]
    end

    # keep the fuzzer happy
    it "doesn't blow up when given a hash" do
      expect(
        lambda {build(:entry_email, recipients: {})}
      ).not_to raise_error
    end

    it "adds errors when recipients are invalid" do
      email.recipients = ["NOT-AN-EMAIL-ADDRESS", "doe@foo_com", "john@example.com"]

      email.valid?
      expect(email.errors[:recipients].size).to eq(2)
    end

    it "allows valid recipients" do
      email.recipients = ["john@example.com"]

      email.valid?
      expect(email.errors[:recipients].size).to eq(0)
    end

    it "adds errors when more than 5 recipients are added" do
      email.recipients = "one@example.com,two@example.com,three@example.com,four@example.com,five@example.com,six@example.com"

      email.valid?
      expect(email.errors[:recipients].size).to eq(1)
    end

    it "allows 5 recipients when 5 are added" do
      email.recipients = "one@example.com,two@example.com,three@example.com,four@example.com,five@example.com"

      email.valid?
      expect(email.errors[:recipients].size).to eq(0)
    end
  end

  describe "#num_recipients (a before_validation hook)" do
    let(:email) { build(:entry_email) }

    it "is calculated based on the number of recipients" do
      email.recipients = "jane@example.com"
      email.valid?
      expect(email.num_recipients).to eq 1

      email.recipients = "jane@example.com, judy@example.com"
      email.valid?
      expect(email.num_recipients).to eq 2
    end
  end

  describe "#requires_captcha_with_message?" do
    it "is true" do
      expect(
        build(:entry_email, remote_ip: '8.8.8.8').requires_captcha_with_message?
      ).to be true
    end
  end

  describe "#requires_captcha_without_message?" do
    it "is true" do
      expect(
        build(:entry_email, remote_ip: '8.8.8.8').requires_captcha_with_message?
      ).to be true
    end
  end

  describe "#requires_captcha?" do
    it "calls requires_captcha_with_message? if message is present" do
      email = build(:entry_email, message: "HI")
      expect_any_instance_of(EntryEmail).to receive(:requires_captcha_with_message?)
      email.requires_captcha?
    end

    it "calls requires_captcha_without_message? if message is not present" do
      email = build(:entry_email)
      expect_any_instance_of(EntryEmail).to receive(:requires_captcha_without_message?)
      email.requires_captcha?
    end
  end
end
