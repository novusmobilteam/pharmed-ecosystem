import { api } from './api';
import { useSession } from './auth';
import { Layout } from './components/Layout';
import { Devices } from './pages/Devices';
import { IssueDetail } from './pages/IssueDetail';
import { Issues } from './pages/Issues';
import { Login } from './pages/Login';
import { Logs } from './pages/Logs';
import { Overview } from './pages/Overview';
import { ServerErrors } from './pages/ServerErrors';
import { Around, Trace } from './pages/Trace';
import { useRoute } from './router';

export function App() {
  const route = useRoute();
  const session = useSession();
  if (!api.isMock && !session) return <Login />;
  const issue = /^\/issues\/([^/]+)$/.exec(route.path);

  let page;
  if (route.path === '/') page = <Overview route={route} />;
  else if (issue) page = <IssueDetail route={route} fingerprint={decodeURIComponent(issue[1])} />;
  else if (route.path === '/issues') page = <Issues route={route} />;
  else if (route.path === '/logs') page = <Logs route={route} />;
  else if (route.path === '/devices') page = <Devices route={route} />;
  else if (route.path === '/server-errors') page = <ServerErrors route={route} />;
  else if (route.path === '/trace') page = <Trace route={route} />;
  else if (route.path === '/around') page = <Around route={route} />;
  else
    page = (
      <div className="state state-empty">
        <strong>Bu sayfa yok.</strong>
        <a href="#/">Genel bakışa dön</a>
      </div>
    );

  return <Layout route={route}>{page}</Layout>;
}
