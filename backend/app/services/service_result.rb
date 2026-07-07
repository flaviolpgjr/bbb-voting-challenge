class ServiceResult
  attr_reader :status, :payload

  def initialize(status:, payload:)
    @status = status
    @payload = payload
  end
end