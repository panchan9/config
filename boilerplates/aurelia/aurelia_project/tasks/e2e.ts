/**
 * e2e task
 *
 * You should have the server up and running before executing this task.
 * e.g. run `au run, otherwise the protractor calls will fail.
 */
import * as del from 'del';
import * as project from '../aurelia.json';
import * as tsConfig from '../../tsconfig.json';
import * as gulp from 'gulp';
import * as plumber from 'gulp-plumber';
import * as notify from 'gulp-notify';
import * as changedInPlace from 'gulp-changed-in-place';
import * as sourcemaps from 'gulp-sourcemaps';
import * as ts from 'gulp-typescript';
import { webdriver_update, protractor } from 'gulp-protractor';


function clean() {
  return del(project.e2eTestRunner.output + '*');
}

function build() {
  var typescriptCompiler = typescriptCompiler || null;
  // delete tsConfig.compilerOptions.lib;
  if ( !typescriptCompiler ) {
    typescriptCompiler = ts.createProject(Object.assign({}, tsConfig.compilerOptions));
  }
  console.log('create typescript conpiler is finished.');

  return gulp.src(project.e2eTestRunner.source)
    .pipe(plumber({
      errorHandler: notify.onError('Error: <%= error.message %>')
    }))
    .pipe(changedInPlace({ firstPass: true }))
    .pipe(sourcemaps.init())
    // .pipe(typescriptCompiler())
    .pipe(gulp.dest(project.e2eTestRunner.output));
}

function run() {
  console.log('run task start.');
  return gulp.src(project.e2eTestRunner.output + '**/*/js')
    .pipe(protractor({
      configFile: 'protractor.conf.js',
      args: ['--baseUrl', 'http://127.0.0.1:9000']
    }))
    .on('end', () => { process.exit(); })
    .on('error', e => { throw e; });
}

export default gulp.series(
  webdriver_update,
  clean,
  build,
  run
);
