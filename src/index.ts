import express, { Express, Request, Response } from 'express';
import chokidar from 'chokidar';
import * as child from 'child_process';

const app: Express = express();
const port = '8080';

app.get('/', (req: Request, res: Response) => {
  res.send('Wholesale Frontend');
});

app.listen(port, () => {
  console.log(
    `⚡️[server]: Wholesale Frontend Server is running at https://localhost:${port}`,
  );
});

console.debug('Process environment', process.env);

chokidar
  .watch('/app/configs/locations.yaml', { alwaysStat: true })
  .on('all', (event, path) => {
    console.log('Chokidar found: ');
    console.log(event, path);
  });

const workspace: child.ChildProcess = child.exec(
  'ls -la /app/configs/locations.yaml && cat /app/configs/locations.yaml',
  (err, output) => {
    console.debug('CMD output: ', output);
  },
);

const workspace2: child.ChildProcess = child.exec(
  'sleep 30 && ls -la /app/configs/locations.yaml && cat /app/configs/locations.yaml',
  (err, output) => {
    console.debug('CMD2 output: ', output);
  },
);
