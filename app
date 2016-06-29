#!/usr/bin/env ruby
require 'sinatra'
require 'mimemagic'

DATA_DIR = ENV['DATA_DIR'] || './data'

def random_file_name
  file_path = Dir["#{DATA_DIR}/*"].sample
  return nil if file_path.nil?
  File.basename file_path
end

get '/' do
  return 404 if !random_file_name
  file_name = random_file_name
  mime_string = MimeMagic.by_extension(File.extname(file_name)).to_s
  if mime_string.start_with? 'image'
    """
    <html><head><meta http-equiv='refresh' content='30'>
      <style>
      #content
      {
          width:100%;
          height:100%;
          background:url(/#{file_name});
          background-size:contain;
          background-repeat:no-repeat;
          background-position:center;
      }
      </style>
    </head><body>
     <div id='content'></div>
    </body></html>
    """
  elsif mime_string.start_with? 'video'
    """
    <html><head>
    </head><body>
     <video width='100%' height='100%' autoplay id='vid'>
      <source src='/#{file_name}'>
     </video>
     <script type='text/javascript'>
      var el = document.getElementById('vid');
      console.log({ el: el });
      document.getElementById('vid').addEventListener('ended',function() {
       console.log('reloading page');
       window.location.reload(true);
      },false);
    </script>
    </body></html>
    """
  else
    """
    <html><head><meta http-equiv='refresh' content='30'></head><body>
    <iframe src='/#{file_name}' width='100%' height='100%'/>
    </body></html>
    """
  end
end

get '/:file_name' do |file_name|
  send_file File.join(DATA_DIR, file_name)
end
