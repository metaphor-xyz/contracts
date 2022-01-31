/*
 * Script to remove some incorrect ABI output produced by forge
 *
 * Foundry issue: https://github.com/gakonst/foundry/issues/618
 * Fix PR: https://github.com/rust-ethereum/ethabi/pull/259
 *
 * Once fix PR is merged, we can remove this script
 *
 */

const fs = require('fs');

function walk(dir) {
  const files = fs.readdirSync(dir);

  for (const file of files) {
    if (fs.statSync(dir + file).isDirectory()) {
      walk(dir + file + '/');
    } else if (new RegExp(/\.json/).test(file)) {
      const raw = fs.readFileSync(dir + file);
      const content = JSON.parse(raw);

      if (content['abi']) {
        for (const obj of content['abi']) {
          if (obj.constant === null) {
            obj.constant = undefined;
          }
        }
      }

      fs.writeFileSync(dir + file, JSON.stringify(content, null, 2));
    }
  }
}

walk('./out/');
