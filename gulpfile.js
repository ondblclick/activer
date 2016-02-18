var gulp = require('gulp');
var coffee = require ('gulp-coffee');
var sass = require ('gulp-sass');
var gutil = require ('gulp-util');
var clean = require('gulp-clean');
var server = require('gulp-webserver');
var KarmaServer = require('karma').Server;

gulp.task('styles', function() {
  return gulp.src('./app/stylesheets/*.scss')
    .pipe(sass({ style: 'expanded' }).on('error', gutil.log))
    .pipe(gulp.dest('./dist/stylesheets'));
});

gulp.task('coffee', function() {
  return gulp.src('./app/javascripts/*.coffee')
    .pipe(coffee({ bare: true }).on('error', gutil.log))
    .pipe(gulp.dest('./dist/javascripts'));
});

gulp.task('images', function() {
  return gulp.src('./app/images/*.*')
    .pipe(gulp.dest('./dist/images'));
});

gulp.task('markup', function() {
  return gulp.src('./app/*.html')
    .pipe(gulp.dest('./dist'));
});

gulp.task('clean', function() {
  return gulp.src(['./dist'], { read: false })
    .pipe(clean());
});

gulp.task('default', ['clean'], function() {
  return gulp.run('styles', 'coffee', 'images', 'markup');
});

gulp.task('server', ['watch'], function() {
  gulp.src('./dist')
    .pipe(server({ livereload: true, open: true }));
});

gulp.task('test', function (done) {
  new KarmaServer({
    configFile: __dirname + '/karma.conf.js',
    singleRun: true
  }, done).start();
});

gulp.task('watch', function() {
  var eventMessage = function(event) {
    console.log('File ' + event.path + ' was ' + event.type + ', running tasks...');
  }

  gulp.watch('./app/stylesheets/*.scss', function(event) {
    eventMessage(event);
    gulp.run('styles');
  });

  gulp.watch('./app/javascripts/*.coffee', function(event) {
    eventMessage(event);
    gulp.run('coffee');
  });

  gulp.watch('./app/images/*.*', function(event) {
    eventMessage(event);
    gulp.run('images');
  });

  gulp.watch('./app/*.html', function(event) {
    eventMessage(event);
    gulp.run('markup');
  });
});
