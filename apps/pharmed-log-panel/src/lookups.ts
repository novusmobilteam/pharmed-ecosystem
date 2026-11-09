// Kiosk ve istasyon adları — listelerde id yerine isim göstermek için.

import { useEffect, useState } from 'react';
import { api, type Device } from './api';

let cache: Promise<Device[]> | null = null;

export function loadDevices(force = false) {
  if (!cache || force) cache = api.devices().catch(() => []);
  return cache;
}

export function useDevices(): Device[] {
  const [devices, setDevices] = useState<Device[]>([]);
  useEffect(() => {
    let alive = true;
    loadDevices().then((d) => alive && setDevices(d));
    return () => {
      alive = false;
    };
  }, []);
  return devices;
}

export function useDeviceName() {
  const devices = useDevices();
  return (id?: string) => devices.find((d) => d.deviceId === id)?.hostName ?? (id ? id.slice(0, 8) : '—');
}

export function useStationName() {
  const devices = useDevices();
  return (id?: number) => devices.find((d) => d.stationId === id)?.stationName ?? (id !== undefined ? `İstasyon ${id}` : '—');
}
