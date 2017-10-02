import { CLIOptions } from 'aurelia-cli';
import * as gulp from 'gulp';
import * as project from '../aurelia.json';

export default function copy() {
  const output = CLIOptions.getFlagValue('out', 'o');
  if (!output) {
    throw new Error('--out argument is required');
  }

  return gulp.src(project.deploy.sources, { base: './' })
    .pipe(gulp.dest(output));
}
