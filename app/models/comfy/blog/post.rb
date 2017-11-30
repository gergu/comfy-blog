class Comfy::Blog::Post < ActiveRecord::Base

  self.table_name = 'comfy_blog_posts'

  include Comfy::Cms::WithFragments
  include Comfy::Cms::WithCategories

  # -- Relationships -----------------------------------------------------------
  belongs_to :site,
    class_name: 'Comfy::Cms::Site'

  # -- Validations -------------------------------------------------------------
  validates :title, :slug, :year, :month,
    presence: true
  validates :slug,
    uniqueness: {scope: [:site_id, :year, :month]},
    format:     {with: /\A%*\w[a-z0-9_\-\%]*\z/i }

  # -- Scopes ------------------------------------------------------------------
  scope :published, -> {where(is_published: true)}
  scope :for_year,  -> year {where(year: year)}
  scope :for_month, -> month {where(month: month)}

  # -- Callbacks ---------------------------------------------------------------
  before_validation :set_slug,
                    :set_published_at,
                    :set_date

  # -- Instance Mathods --------------------------------------------------------
  def url(relative: false)
    public_blog_path = ComfyBlog.config.public_blog_path
    post_path = ['/', public_blog_path, self.year, self.month, self.slug].join('/').squeeze('/')
    [self.site.url(relative: relative), post_path].join
  end

protected

  def set_slug
    self.slug ||= self.title.to_s.parameterize
  end

  def set_date
    self.year   = self.published_at.year
    self.month  = self.published_at.month
  end

  def set_published_at
    self.published_at ||= Time.zone.now
  end
end
