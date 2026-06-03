import { useCallback, useEffect, useMemo, useState } from 'react';
import {
  App as AntApp,
  Button,
  DatePicker,
  Dropdown,
  Form,
  Input,
  InputNumber,
  Modal,
  Select,
  Space,
  Switch,
  Table,
  Tag,
  Typography,
} from 'antd';
import {
  AppstoreOutlined,
  BarChartOutlined,
  BellOutlined,
  BulbOutlined,
  ClockCircleOutlined,
  CloseOutlined,
  DeleteOutlined,
  DownOutlined,
  EditOutlined,
  EyeOutlined,
  FileTextOutlined,
  HomeOutlined,
  LogoutOutlined,
  PlusOutlined,
  ProductOutlined,
  ReloadOutlined,
  SearchOutlined,
  SettingOutlined,
  ShopOutlined,
  TeamOutlined,
  UserOutlined,
} from '@ant-design/icons';
import dayjs from 'dayjs';
import { api, auth } from './api/client';
import { getOptionLabel, getRecordLabel, resourceMap, resources } from './config/resources';

const { Title, Text } = Typography;

const groupIcons = {
  '认证与权限': <UserOutlined />,
  '组织与店铺': <ShopOutlined />,
  主数据: <ProductOutlined />,
  业务单据: <AppstoreOutlined />,
  报表配置: <FileTextOutlined />,
};

const statusColor = {
  active: 'green',
  disabled: 'default',
  locked: 'red',
  draft: 'default',
  approved: 'blue',
  in_transit: 'gold',
  received: 'green',
  posted: 'green',
  cancelled: 'red',
};

function formatDateTime(value) {
  if (!value) return '-';
  const parsed = dayjs(value);
  return parsed.isValid() ? parsed.format('YYYY-MM-DD HH:mm') : String(value);
}

function formatDate(value) {
  if (!value) return '-';
  const parsed = dayjs(value);
  return parsed.isValid() ? parsed.format('YYYY-MM-DD') : String(value);
}

function isWritableField(field, editing) {
  if (field.readOnly) return false;
  if (field.createOnly && editing?.id) return false;
  return true;
}

function getRowKey(resource) {
  return resource.primaryKey || 'id';
}

function getRelatedResources(resource) {
  return Array.from(new Set(resource.fields
    .filter((field) => field.resource)
    .map((field) => field.resource)));
}

function getInitialValues(record, resource) {
  if (!record) return {};
  const values = { ...record };
  resource.fields.forEach((field) => {
    if ((field.type === 'date' || field.type === 'datetime') && values[field.name]) {
      const parsed = dayjs(values[field.name]);
      values[field.name] = parsed.isValid() ? parsed : undefined;
    }
  });
  return values;
}

function normalizePayload(values, resource, editing) {
  const payload = {};
  resource.fields.forEach((field) => {
    if (!isWritableField(field, editing)) return;
    if (!(field.name in values)) return;
    let value = values[field.name];
    if (field.type === 'date') {
      value = value ? dayjs(value).format('YYYY-MM-DD') : null;
    }
    if (field.type === 'datetime') {
      value = value ? dayjs(value).toISOString() : null;
    }
    if (field.type === 'password' && editing?.id && !value) return;
    if (value === undefined) return;
    payload[field.name] = value;
  });
  return payload;
}

function renderDisplayValue(value, field, lookups) {
  if (value === null || value === undefined || value === '') return '-';
  if (field.type === 'boolean') return value ? <Tag color="green">是</Tag> : <Tag>否</Tag>;
  if (field.type === 'select') {
    return <Tag color={statusColor[value] || 'blue'}>{getOptionLabel(field.options, value)}</Tag>;
  }
  if (field.type === 'date') return formatDate(value);
  if (field.type === 'datetime') return formatDateTime(value);
  if (field.type === 'foreign') {
    const related = lookups[field.resource]?.byId?.[value];
    return getRecordLabel(related) || value;
  }
  if (field.type === 'foreign-multiple') {
    const values = Array.isArray(value) ? value : [];
    return values.length
      ? values.map((id) => getRecordLabel(lookups[field.resource]?.byId?.[id]) || id).join('、')
      : '-';
  }
  if (field.type === 'number' && value !== '') {
    return Number.isNaN(Number(value)) ? value : Number(value).toLocaleString('zh-CN');
  }
  return String(value);
}

function renderFormControl(field, lookups) {
  if (field.type === 'textarea') return <Input.TextArea rows={3} placeholder={`请输入${field.label}`} />;
  if (field.type === 'password') return <Input.Password placeholder="留空表示不修改" autoComplete="new-password" />;
  if (field.type === 'number') {
    return <InputNumber min={field.min} precision={field.precision} style={{ width: '100%' }} placeholder={`请输入${field.label}`} />;
  }
  if (field.type === 'boolean') return <Switch checkedChildren="是" unCheckedChildren="否" />;
  if (field.type === 'select') return <Select allowClear options={field.options} placeholder={`请选择${field.label}`} />;
  if (field.type === 'date') return <DatePicker style={{ width: '100%' }} />;
  if (field.type === 'datetime') return <DatePicker showTime style={{ width: '100%' }} />;
  if (field.type === 'foreign' || field.type === 'foreign-multiple') {
    const options = (lookups[field.resource]?.items || []).map((item) => ({
      label: getRecordLabel(item),
      value: item[getRowKey(resourceMap[field.resource])],
    }));
    return (
      <Select
        allowClear
        showSearch
        mode={field.type === 'foreign-multiple' ? 'multiple' : undefined}
        optionFilterProp="label"
        options={options}
        placeholder={`请选择${field.label}`}
      />
    );
  }
  return <Input placeholder={`请输入${field.label}`} />;
}

function LoginPage({ onLogin }) {
  const { message } = AntApp.useApp();
  const [loading, setLoading] = useState(false);

  const submit = async (values) => {
    setLoading(true);
    try {
      const session = await auth.login(values);
      message.success('登录成功');
      onLogin(session);
    } catch (error) {
      message.error(error.message || '登录失败');
    } finally {
      setLoading(false);
    }
  };

  return (
    <main className="login-page">
      <section className="card login-card">
        <div className="workspace-avatar">外</div>
        <Title level={2}>外贸通电商智控系统</Title>
        <Text type="secondary">数据库课程大作业前端控制台</Text>
        <Form
          layout="vertical"
          className="login-form"
          onFinish={submit}
          initialValues={{ username: 'admin', password: 'admin123' }}
        >
          <Form.Item label="账号" name="username" rules={[{ required: true, message: '请输入账号' }]}>
            <Input autoComplete="username" placeholder="admin" />
          </Form.Item>
          <Form.Item label="密码" name="password" rules={[{ required: true, message: '请输入密码' }]}>
            <Input.Password autoComplete="current-password" placeholder="admin123" />
          </Form.Item>
          <Button className="btn btn-primary" type="primary" htmlType="submit" block loading={loading}>
            登录系统
          </Button>
        </Form>
      </section>
    </main>
  );
}

function Sidebar({ activeKey, onChange }) {
  const groups = useMemo(() => resources.reduce((acc, resource) => {
    acc[resource.group] ||= [];
    acc[resource.group].push(resource);
    return acc;
  }, {}), []);

  return (
    <aside className="sidebar">
      <button type="button" className="workspace-switcher" onClick={() => onChange('home')}>
        <div className="workspace-avatar">外</div>
        <span>外贸通</span>
        <span className="workspace-caret"><DownOutlined /></span>
      </button>
      <div className="sidebar-label">工作台</div>
      <nav className="sidebar-section">
        <button type="button" className={`sidebar-item ${activeKey === 'home' ? 'active' : ''}`} onClick={() => onChange('home')}>
          <HomeOutlined />
          <span>首页</span>
        </button>
      </nav>
      {Object.entries(groups).map(([group, items]) => (
        <div key={group}>
          <div className="sidebar-label">{group}</div>
          <nav className="sidebar-section">
            {items.map((item) => (
              <button
                type="button"
                key={item.key}
                className={`sidebar-item ${activeKey === item.key ? 'active' : ''}`}
                onClick={() => onChange(item.key)}
                title={item.label}
              >
                {groupIcons[group] || <AppstoreOutlined />}
                <span>{item.label}</span>
              </button>
            ))}
          </nav>
        </div>
      ))}
      <div className="sidebar-bottom">
        <span>数据库大作业</span>
      </div>
    </aside>
  );
}

function Topbar({ keyword, onKeywordChange, onRefresh, user, onLogout }) {
  const menu = {
    items: [
      { key: 'user', label: user?.username || '当前用户', icon: <UserOutlined />, disabled: true },
      { type: 'divider' },
      { key: 'logout', label: '退出登录', icon: <LogoutOutlined /> },
    ],
    onClick: ({ key }) => {
      if (key === 'logout') onLogout();
    },
  };

  return (
    <header className="topbar">
      <div className="search-box">
        <SearchOutlined />
        <Input
          bordered={false}
          value={keyword}
          onChange={(event) => onKeywordChange(event.target.value)}
          placeholder="搜索当前模块"
          allowClear
        />
      </div>
      <div className="topbar-actions">
        <ReloadOutlined onClick={onRefresh} title="刷新" />
        <BellOutlined />
        <SettingOutlined />
        <Dropdown menu={menu} placement="bottomRight">
          <button type="button" className="topbar-user">
            <span>{user?.username || '用户'}</span>
            <DownOutlined />
          </button>
        </Dropdown>
      </div>
    </header>
  );
}

function DashboardHome({ onOpen }) {
  const { message } = AntApp.useApp();
  const [loading, setLoading] = useState(false);
  const [stats, setStats] = useState({
    products: [],
    balances: [],
    sales: [],
    purchases: [],
    reports: [],
    users: [],
  });

  const load = useCallback(async () => {
    setLoading(true);
    try {
      const [products, balances, sales, purchases, reports, users] = await Promise.all([
        api.list('/api/operations/products/'),
        api.list('/api/operations/inventory-balances/'),
        api.list('/api/operations/sales-documents/'),
        api.list('/api/operations/purchase-orders/'),
        api.list('/api/operations/report-query-models/'),
        api.list('/api/auth/users/'),
      ]);
      setStats({ products, balances, sales, purchases, reports, users });
    } catch (error) {
      message.error(error.message || '首页数据加载失败');
    } finally {
      setLoading(false);
    }
  }, [message]);

  useEffect(() => {
    load();
  }, [load]);

  const totalSales = stats.sales.reduce((sum, item) => sum + Number(item.total_amount || 0), 0);
  const lowStock = stats.balances.filter((item) => {
    const product = stats.products.find((target) => target.id === item.product);
    return product?.safety_stock !== null && product?.safety_stock !== undefined && Number(item.quantity) <= Number(product.safety_stock);
  });
  const pendingPurchases = stats.purchases.filter((item) => ['draft', 'approved', 'in_transit'].includes(item.status));

  const cards = [
    { title: '销售额', value: `¥${totalSales.toLocaleString('zh-CN', { minimumFractionDigits: 2 })}`, meta: `${stats.sales.length} 张销售单据`, kind: 'line' },
    { title: '库存预警', value: lowStock.length, meta: `${stats.balances.length} 条库存余额`, kind: 'empty' },
    { title: '待处理采购', value: pendingPurchases.length, meta: '草稿、已审核、在途订单', kind: 'dotted' },
    { title: '报表模型', value: stats.reports.length, meta: `${stats.users.length} 个系统用户`, kind: 'flat' },
  ];

  return (
    <>
      <section className="today-section">
        <div className="section-head">
          <div>
            <h1>今天</h1>
            <p>基于 Django 后端实时汇总的经营概览。</p>
          </div>
          <button type="button" className="small-outline" onClick={load}><ReloadOutlined />刷新</button>
        </div>
        <div className="today-grid">
          <div className="today-main">
            <div className="money-row">
              <div>
                <button type="button" className="metric-select">销售额<DownOutlined /></button>
                <strong>{cards[0].value}</strong>
                <span>{loading ? '正在同步' : formatDateTime(new Date().toISOString())}</span>
              </div>
              <div>
                <button type="button" className="metric-select">库存余额<DownOutlined /></button>
                <strong>{stats.balances.reduce((sum, item) => sum + Number(item.quantity || 0), 0).toLocaleString('zh-CN')}</strong>
              </div>
            </div>
            <div className="timeline">
              <span>00:00</span>
              <div className="timeline-line" />
              <span>24:00</span>
            </div>
            <div className="balance-row">
              <div>
                <button type="button" className="metric-select">业务单据<DownOutlined /></button>
                <strong>{stats.sales.length + stats.purchases.length}</strong>
              </div>
              <a onClick={() => onOpen('salesDocuments')}>查看销售单据</a>
            </div>
          </div>
          <aside className="recommend-card">
            <button type="button" className="close-button"><CloseOutlined /></button>
            <h3>待处理事项</h3>
            <p>{lowStock.length} 个库存余额低于安全库存，需要复核补货。</p>
            <a onClick={() => onOpen('inventoryBalances')}>查看库存</a>
            <p>{pendingPurchases.length} 张采购订单仍在处理中。</p>
            <a onClick={() => onOpen('purchaseOrders')}>进入采购</a>
            <div className="api-box">
              <div>
                <strong>后端状态</strong>
                <a onClick={() => onOpen('users')}>认证接口</a>
              </div>
              <p><span>JWT</span><code>/api/auth/login/</code></p>
              <p><span>业务</span><code>/api/operations/products/</code></p>
            </div>
          </aside>
        </div>
      </section>
      <section className="overview-section">
        <div className="section-head overview-head">
          <div>
            <h2>您的概览</h2>
            <div className="filter-row">
              <span>日期范围&nbsp;&nbsp;最近 7 天<DownOutlined /></span>
              <span>粒度&nbsp;&nbsp;每天<DownOutlined /></span>
              <span>来源&nbsp;&nbsp;Django API<DownOutlined /></span>
            </div>
          </div>
          <Space>
            <button type="button" className="small-outline" onClick={() => onOpen('reportQueryModels')}>报表模型</button>
            <button type="button" className="small-outline" onClick={() => onOpen('metrics')}>指标定义</button>
          </Space>
        </div>
        <div className="overview-grid compact-overview">
          {cards.map((card) => (
            <div className="overview-card" key={card.title}>
              <div className="card-title-row">
                <span>{card.title}</span>
                <button type="button">...</button>
              </div>
              <strong>{card.value}</strong>
              <p>{card.meta}</p>
              <div className={`chart-placeholder ${card.kind}`}>
                {card.kind === 'empty' ? <span>{lowStock.length ? '需要关注' : '暂无预警'}</span> : null}
              </div>
            </div>
          ))}
        </div>
      </section>
    </>
  );
}

function ResourcePage({ resource, globalKeyword, refreshSignal }) {
  const { message } = AntApp.useApp();
  const [data, setData] = useState([]);
  const [lookups, setLookups] = useState({});
  const [loading, setLoading] = useState(false);
  const [keyword, setKeyword] = useState('');
  const [filters, setFilters] = useState({});
  const [ordering, setOrdering] = useState('');
  const [editing, setEditing] = useState(null);
  const [viewing, setViewing] = useState(null);
  const [form] = Form.useForm();
  const rowKey = getRowKey(resource);

  const effectiveKeyword = globalKeyword || keyword;

  const loadLookups = useCallback(async () => {
    const relatedKeys = getRelatedResources(resource);
    if (!relatedKeys.length) {
      setLookups({});
      return;
    }
    const entries = await Promise.all(relatedKeys.map(async (key) => {
      const related = resourceMap[key];
      const items = related ? await api.list(related.path) : [];
      const relatedKey = related ? getRowKey(related) : 'id';
      return [key, {
        items,
        byId: Object.fromEntries(items.map((item) => [item[relatedKey], item])),
      }];
    }));
    setLookups(Object.fromEntries(entries));
  }, [resource]);

  const loadData = useCallback(async () => {
    setLoading(true);
    try {
      const params = { ...filters, search: effectiveKeyword, ordering };
      const items = await api.list(resource.path, params);
      setData(items);
    } catch (error) {
      message.error(error.message || `${resource.label}加载失败`);
    } finally {
      setLoading(false);
    }
  }, [effectiveKeyword, filters, message, ordering, resource]);

  useEffect(() => {
    loadLookups().catch((error) => message.error(error.message || '关联数据加载失败'));
  }, [loadLookups, message]);

  useEffect(() => {
    loadData();
  }, [loadData, refreshSignal]);

  const openCreate = () => {
    setEditing({});
    form.resetFields();
    const defaults = {};
    resource.fields.forEach((field) => {
      if (field.type === 'boolean') defaults[field.name] = false;
    });
    form.setFieldsValue(defaults);
  };

  const openEdit = (record) => {
    setEditing(record);
    form.setFieldsValue(getInitialValues(record, resource));
  };

  const saveRecord = async () => {
    const values = await form.validateFields();
    const payload = normalizePayload(values, resource, editing);
    try {
      if (editing?.[rowKey]) {
        await api.update(resource.path, editing[rowKey], payload);
        message.success('已更新');
      } else {
        await api.create(resource.path, payload);
        message.success('已新增');
      }
      setEditing(null);
      await loadLookups();
      await loadData();
    } catch (error) {
      message.error(error.message || '保存失败');
    }
  };

  const deleteRecord = (record) => {
    Modal.confirm({
      title: `确认删除 ${getRecordLabel(record)}？`,
      okText: '删除',
      cancelText: '取消',
      okButtonProps: { danger: true },
      onOk: async () => {
        try {
          await api.remove(resource.path, record[rowKey]);
          message.success('已删除');
          await loadData();
        } catch (error) {
          message.error(error.message || '删除失败');
        }
      },
    });
  };

  const tableColumns = [
    ...resource.fields.filter((field) => !field.hideInTable).map((field) => ({
      title: field.label,
      dataIndex: field.name,
      width: field.width || 130,
      sorter: ['number', 'date', 'datetime'].includes(field.type),
      ellipsis: true,
      render: (value) => renderDisplayValue(value, field, lookups),
    })),
    {
      title: '',
      fixed: 'right',
      width: 168,
      render: (_, record) => (
        <Space size={6} className="row-actions">
          <Button className="row-action" icon={<EyeOutlined />} onClick={() => setViewing(record)}>查看</Button>
          <Button className="row-action" icon={<EditOutlined />} onClick={() => openEdit(record)}>编辑</Button>
          <Button className="row-action danger" icon={<DeleteOutlined />} onClick={() => deleteRecord(record)}>删除</Button>
        </Space>
      ),
    },
  ];

  const filterableFields = resource.fields.filter((field) => !field.readOnly && ['text', 'select', 'foreign', 'boolean', undefined].includes(field.type));

  const handleTableChange = (_, __, sorter) => {
    const field = sorter?.field;
    if (!field || !sorter.order) {
      setOrdering('');
      return;
    }
    setOrdering(`${sorter.order === 'descend' ? '-' : ''}${field}`);
  };

  return (
    <section className="list-page">
      <div className="list-page-head">
        <div>
          <h1>{resource.label}</h1>
          <p>{resource.note}</p>
        </div>
        <Button className="btn btn-primary action-primary" type="primary" icon={<PlusOutlined />} onClick={openCreate}>
          新增
        </Button>
      </div>
      <div className="notice-bar">
        <BulbOutlined />
        <span className="notice-copy">当前页面已接入 {resource.path}，支持搜索、筛选、排序和 CRUD。</span>
        <a onClick={loadData}>立即同步</a>
        <strong><ClockCircleOutlined /> 实时</strong>
      </div>
      <div className="list-tools">
        <div className="chip-row">
          <Input
            className="inline-search"
            prefix={<SearchOutlined />}
            placeholder={`查询${resource.label}`}
            value={keyword}
            onChange={(event) => setKeyword(event.target.value)}
            allowClear
          />
          {filterableFields.slice(0, 5).map((field) => (
            <FilterControl
              key={field.name}
              field={field}
              value={filters[field.name]}
              lookups={lookups}
              onChange={(value) => setFilters((current) => ({ ...current, [field.name]: value === '' ? undefined : value }))}
            />
          ))}
        </div>
        <div className="table-tool-row">
          <button type="button" className="tool-button" onClick={loadData}><ReloadOutlined />刷新</button>
          <button type="button" className="tool-button" onClick={() => setFilters({})}><CloseOutlined />清除筛选</button>
          <button type="button" className="tool-button"><BarChartOutlined />分析</button>
          <button type="button" className="tool-button"><SettingOutlined />列设置</button>
        </div>
      </div>
      <div className="stripe-table-wrap">
        <Table
          className="stripe-data-table"
          rowKey={rowKey}
          loading={loading}
          dataSource={data}
          columns={tableColumns}
          onChange={handleTableChange}
          scroll={{ x: 'max-content' }}
          pagination={{ pageSize: 10, showSizeChanger: true, showTotal: (total) => `共 ${total} 条` }}
        />
      </div>
      <div className="item-count">{data.length} 项</div>

      <Modal
        title={editing?.[rowKey] ? `编辑${resource.label}` : `新增${resource.label}`}
        open={!!editing}
        okText="保存"
        cancelText="取消"
        onOk={saveRecord}
        onCancel={() => setEditing(null)}
        width={720}
        destroyOnClose
      >
        <Form form={form} layout="vertical" className="resource-form">
          {resource.fields.filter((field) => isWritableField(field, editing)).map((field) => (
            <Form.Item
              key={field.name}
              label={field.label}
              name={field.name}
              valuePropName={field.type === 'boolean' ? 'checked' : 'value'}
              rules={[{ required: field.required && !(field.type === 'password' && editing?.[rowKey]), message: `请填写${field.label}` }]}
            >
              {renderFormControl(field, lookups)}
            </Form.Item>
          ))}
        </Form>
      </Modal>

      <Modal title={`${resource.label}详情`} open={!!viewing} footer={null} onCancel={() => setViewing(null)} width={760}>
        <div className="detail-list">
          {viewing && resource.fields.map((field) => (
            <div className="detail-row" key={field.name}>
              <span>{field.label}</span>
              <strong>{renderDisplayValue(viewing[field.name], field, lookups)}</strong>
            </div>
          ))}
        </div>
      </Modal>
    </section>
  );
}

function FilterControl({ field, value, lookups, onChange }) {
  const commonProps = {
    className: 'filter-control',
    size: 'small',
    allowClear: true,
    placeholder: field.label,
    value,
    onChange,
  };
  if (field.type === 'select') return <Select {...commonProps} options={field.options} />;
  if (field.type === 'boolean') return <Select {...commonProps} options={[{ label: '是', value: true }, { label: '否', value: false }]} />;
  if (field.type === 'foreign') {
    const related = resourceMap[field.resource];
    const relatedKey = related ? getRowKey(related) : 'id';
    return (
      <Select
        {...commonProps}
        showSearch
        optionFilterProp="label"
        options={(lookups[field.resource]?.items || []).map((item) => ({ label: getRecordLabel(item), value: item[relatedKey] }))}
      />
    );
  }
  return <Input className="filter-control" size="small" allowClear placeholder={field.label} value={value} onChange={(event) => onChange(event.target.value)} />;
}

function ConsoleApp() {
  const { message } = AntApp.useApp();
  const [session, setSession] = useState(auth.getSession());
  const [activeKey, setActiveKey] = useState('home');
  const [globalKeyword, setGlobalKeyword] = useState('');
  const [refreshSignal, setRefreshSignal] = useState(0);

  useEffect(() => {
    const handler = (event) => setSession(event.detail);
    window.addEventListener('session-change', handler);
    return () => window.removeEventListener('session-change', handler);
  }, []);

  const logout = async () => {
    try {
      await auth.logout();
      message.success('已退出登录');
    } catch (error) {
      message.error(error.message || '退出失败');
    }
  };

  if (!session?.access) {
    return <LoginPage onLogin={setSession} />;
  }

  const activeResource = resourceMap[activeKey];

  return (
    <div className="console-shell">
      <Sidebar activeKey={activeKey} onChange={(key) => {
        setActiveKey(key);
        setGlobalKeyword('');
      }} />
      <Topbar
        keyword={globalKeyword}
        onKeywordChange={setGlobalKeyword}
        onRefresh={() => setRefreshSignal((value) => value + 1)}
        user={session.user}
        onLogout={logout}
      />
      <main className="console-main">
        <div className="content-column">
          {activeKey === 'home'
            ? <DashboardHome onOpen={setActiveKey} />
            : <ResourcePage resource={activeResource} globalKeyword={globalKeyword} refreshSignal={refreshSignal} />}
        </div>
      </main>
      <div className="developer-bar">
        <span>开发人员</span>
        <span>外贸通 · 陈炀嘉 · 邝文濠 · 苏秉铂</span>
      </div>
    </div>
  );
}

export default function RootApp() {
  return (
    <AntApp>
      <ConsoleApp />
    </AntApp>
  );
}
