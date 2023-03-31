module DocumentLookup
  extend ActiveSupport::Concern

  private

  def find_document
    begin
      if publication_date
        @document = Document.find(document_number, publication_date: publication_date)
      else
        @document = Document.find(document_number)
      end
    rescue FederalRegister::Client::RecordNotFound
      begin
        @document = PublicInspectionDocument.find(params[:document_number])
      rescue FederalRegister::Client::RecordNotFound
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  def document_number
    # replace endash, emdash with hyphen
    hyphen, en_dash, em_dash = "-", "–", "—"
    params[:document_number].gsub(/[#{en_dash}#{em_dash}]/, hyphen)
  end

  def publication_date
    begin
      Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    rescue
      nil
    end
  end

end
