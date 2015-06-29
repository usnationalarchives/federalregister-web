var browserSync = require('browser-sync').create('Federal Register');
var fs          = require("fs");

var gulp        = require('gulp');
//var newer       = require('gulp-newer');
var rename      = require("gulp-rename");
var replace     = require('gulp-replace');
var sass        = require('gulp-sass');
var sourcemaps  = require('gulp-sourcemaps');


var config = {
  sass: {
    includes: [
      './app/assets/stylesheets/application.css.scss'
    ],
    // loaded from .asset_paths.json below
    includePaths: []
  }
};

gulp.task('getAssetPaths', function() {
  var cwd = process.cwd();

  var data = JSON.parse(
    fs.readFileSync(cwd + "/.asset_paths.json").toString()
  );

  config.sass.includePaths = data.stylesheets;
  return config.sass;
});

var browserSyncConfig = {
  files: 'public/assets/application.css',
  proxy: "http://www.fr2.dev:8080",
  reloadDebounce: 300,
  ui: {
    port: 3010,
    weinre: {
        port: 9090
    }
  }
}

// Static Server + watching scss/html files
gulp.task('serve', ['sass'], function() {
  browserSync.init(browserSyncConfig);

  gulp.watch('./app/assets/stylesheets/**/*', ['sass']);
  gulp.watch("app/views/**/*.html.erb").on('change', browserSync.reload);
});

// Compile sass into CSS & auto-inject into browsers
gulp.task('sass', ['getAssetPaths'], function() {
  return gulp.src('./app/assets/stylesheets/application.css.scss')
    .pipe(sourcemaps.init())
    .pipe(
      sass({includePaths: config.sass.includePaths}).on('error', sass.logError)
    )
    .pipe(sourcemaps.write())
    .pipe(rename("application.css"))
    .pipe(
      replace(
        /asset-url\("([\/.\w\?\#]*)",\ "([\/.\w]*)"\)/g,
        'url(/assets/$1)'
      )
    )
    .pipe(
      replace(
        /image-url\("([\/.\w\?\#]*)"\)/g,
        'url(/assets/$1)'
      )
    )
    .pipe(gulp.dest("public/assets"))
    .pipe(browserSync.stream({match: '**/*.css'}));
});

gulp.task('default', ['serve']);
