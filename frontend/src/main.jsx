import React from 'react';
import ReactDOM from 'react-dom/client';
import { ConfigProvider } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import App from './App.jsx';
import './styles.css';

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <ConfigProvider
      locale={zhCN}
      theme={{
        token: {
          colorPrimary: '#635bff',
          colorInfo: '#0a84ff',
          borderRadius: 10,
          fontFamily:
            'Inter, ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif',
        },
        components: {
          Button: {
            controlHeight: 36,
            borderRadius: 8,
            primaryShadow: '0 8px 18px rgba(99, 91, 255, 0.22)',
          },
          Card: {
            borderRadiusLG: 12,
          },
          Layout: {
            bodyBg: '#f6f8fc',
            siderBg: '#ffffff',
            headerBg: '#ffffff',
          },
        },
      }}
    >
      <App />
    </ConfigProvider>
  </React.StrictMode>,
);
