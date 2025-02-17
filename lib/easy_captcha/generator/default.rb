module EasyCaptcha
  module Generator

    # default generator
    class Default < Base

      # set default values
       def defaults
         @font_size              = 28
         @font_fill_color        = '#333333'
         @font                   = File.expand_path('../../../../resources/captcha.ttf', __FILE__)
         @font_stroke            = '#000000'
         @font_stroke_color      = 0
         @image_background_color = '#FFFFFF'
         @sketch                 = true
         @sketch_radius          = 3
         @sketch_sigma           = 1
         @wave                   = true
         @wave_length            = (60..100)
         @wave_amplitude         = (3..5)
         @implode                = 0.05
         @blur                   = true
         @blur_radius            = 1
         @blur_sigma             = 2
         @x_axis                 = 5
         @y_axis                 = 25
         @captcha_image_path     = File.expand_path('../../../../resources/captcha.png', __FILE__)
       end

      # Font
      attr_accessor :font_size, :font_fill_color, :font, :font_family, :font_stroke, :font_stroke_color

      # Text coordinates
      attr_accessor :x_axis, :y_axis

      # folder
      attr_accessor :captcha_image_path

      # Background
      attr_accessor :image_background_color, :background_image

      # Sketch
      attr_accessor :sketch, :sketch_radius, :sketch_sigma

      # Wave
      attr_accessor :wave, :wave_length, :wave_amplitude

      # Implode
      attr_accessor :implode

      # Gaussian Blur
      attr_accessor :blur, :blur_radius, :blur_sigma

    #   def sketch? #:nodoc:
    #     @sketch
    #   end

    #   def wave? #:nodoc:
    #     @wave
    #   end

    #   def blur? #:nodoc:
    #     @blur
    #   end

    #   # generate image
    #   def generate(code)
    #     require 'rmagick' unless defined?(Magick)

    #     config = self
    #     canvas = Magick::Image.new(EasyCaptcha.image_width, EasyCaptcha.image_height) do |variable|
    #       self.background_color = config.image_background_color unless config.image_background_color.nil?
    #       self.background_color = 'none' if config.background_image.present?
    #     end

    #     # Render the text in the image
    #     canvas.annotate(Magick::Draw.new, 0, 0, 0, 0, code) {
    #       self.gravity     = Magick::CenterGravity
    #       self.font        = config.font
    #       self.font_weight = Magick::LighterWeight
    #       self.fill        = config.font_fill_color
    #       if config.font_stroke.to_i > 0
    #         self.stroke       = config.font_stroke_color
    #         self.stroke_width = config.font_stroke
    #       end
    #       self.pointsize = config.font_size
    #     }

    #     # Blur
    #     canvas = canvas.blur_image(config.blur_radius, config.blur_sigma) if config.blur?

    #     # Wave
    #     w = config.wave_length
    #     a = config.wave_amplitude
    #     canvas = canvas.wave(rand(a.last - a.first) + a.first, rand(w.last - w.first) + w.first) if config.wave?

    #     # Sketch
    #     canvas = canvas.sketch(config.sketch_radius, config.sketch_sigma, rand(180)) if config.sketch?

    #     # Implode
    #     canvas = canvas.implode(config.implode.to_f) if config.implode.is_a? Float

    #     # Crop image because to big after waveing
    #     canvas = canvas.crop(Magick::CenterGravity, EasyCaptcha.image_width, EasyCaptcha.image_height)

        # Render the text in the image
        # canvas.annotate(Magick::Draw.new, 0, 0, 0, 0, code) {
        #   self.gravity     = Magick::CenterGravity
        #   self.font        = config.font
        #   self.font_weight = Magick::LighterWeight
        #   self.fill        = config.font_fill_color
        #   if config.font_stroke.to_i > 0
        #     self.stroke       = config.font_stroke_color
        #     self.stroke_width = config.font_stroke
        #   end
        #   self.pointsize = config.font_size
        # }

    #     # Combine images if background image is present
    #     if config.background_image.present?
    #       background = Magick::Image.read(config.background_image).first
    #       background.composite!(canvas, Magick::CenterGravity, Magick::OverCompositeOp)

    #       image = background.to_blob { self.format = 'PNG' }
    #     else
    #       image = canvas.to_blob { self.format = 'PNG' }
    #     end

    #     # ruby-1.9
    #     image = image.force_encoding 'UTF-8' if image.respond_to? :force_encoding

    #     canvas.destroy!
    #     image
    #   end

    # Generate image and store in public/images folder of your code by name 'captcha.png'
    # captcha.png is a rotated image file.
    def generate(code)
      require 'rmagick' unless defined?(Magick)
      begin
        config = self
        canvas = Magick::Image.new(EasyCaptcha.image_width, EasyCaptcha.image_height)
        image_drawer = Magick::Draw.new
        image_drawer.pointsize(config.font_size)
        image_drawer.text(config.x_axis, config.y_axis, code.center(9)) 
        image_drawer.font=config.font
        image_drawer.draw(canvas)
        canvas = apply_distortion!(canvas)
        canvas.write(config.captcha_image_path)
        image = File.read(config.captcha_image_path)
      rescue => e
        Rails.logger.info("Error in generating EasyCaptcha: #{e.message}")
      end
    end

    def apply_distortion!(image)
      image = image.blur_image(1.50, 2.0)
      image = image.wave *random_wave_distortion
      image = image.implode random_implode_distortion
      image = image.swirl rand(10)
      image = image.add_noise Magick::GaussianNoise
      image
    end

    def random_wave_distortion
      [0.5]
    end

    def random_implode_distortion
      (2 + rand(2)) / 10.0
    end

    end
  end
end
