class IpsByAuthors
  def self.call
    Post
      .select('ip, ARRAY_AGG(DISTINCT users.login) AS logins')
      .joins(:user)
      .group('ip')
      .having('COUNT(DISTINCT users.id) > 1')
      .map { |record| { ip: record.ip, logins: record.logins } }
  end
end
