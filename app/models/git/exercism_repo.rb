class Git::ExercismRepo

  REPO_BASE="#{Rails.root}/tmp/git_repo_cache"

  attr_reader :repo_url

  def initialize(repo_url, auto_fetch=false)
    @repo_url = repo_url
    @auto_fetch = auto_fetch
  end

  def config
    config_pointer = repo.branches['master'].target.tree['config.json']
    config_blob = repo.lookup(config_pointer[:oid])
    JSON.parse(config_blob.text, symbolize_names: true)
  end

  def fetch!
    repo.fetch('origin')
  end

  private

  def repo
    @repo ||= if repo_dir_exists?
      r = Rugged::Repository.new(repo_dir)
      r.fetch('origin') if auto_fetch?
      r
    else
      Rugged::Repository.clone_at(repo_url, repo_dir, bare: true)
    end
  end

  def auto_fetch?
    !! @auto_fetch
  end

  def repo_dir_exists?
    File.directory?(repo_dir)
  end

  def repo_dir
    "#{REPO_BASE}/#{url_hash}-#{local_name}"
  end

  def url_hash
    Digest::SHA1.hexdigest(repo_url)
  end

  def local_name
    repo_url.split("/").last
  end
end
