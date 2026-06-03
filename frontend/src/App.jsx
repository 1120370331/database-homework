import { useMemo, useState } from 'react';
import {
  App,
  Button,
  DatePicker,
  Form,
  Input,
  Modal,
  Select,
  Space,
  Table,
  Typography,
} from 'antd';
import {
  AppstoreOutlined,
  BarChartOutlined,
  BellOutlined,
  BulbOutlined,
  ClockCircleOutlined,
  CloseOutlined,
  ColumnHeightOutlined,
  CopyOutlined,
  DeleteOutlined,
  DownOutlined,
  EditOutlined,
  ExportOutlined,
  EyeOutlined,
  FileTextOutlined,
  FilterOutlined,
  HomeOutlined,
  PlusOutlined,
  ProductOutlined,
  SearchOutlined,
  SettingOutlined,
  UserOutlined,
} from '@ant-design/icons';

const { RangePicker } = DatePicker;
const { Title, Text } = Typography;

const initialUsers = [
  {
    id: 1,
    name: '陈炜嘉',
    role: '管理员',
    email: 'chen@example.com',
    status: '启用',
    createdAt: '2026-04-12 下午1:45',
    lastLogin: '2026-06-03 上午9:10',
  },
  {
    id: 2,
    name: '邝文涛',
    role: '运营',
    email: 'kuang@example.com',
    status: '启用',
    createdAt: '2026-04-08 下午9:26',
    lastLogin: '2026-06-02 下午5:32',
  },
  {
    id: 3,
    name: '苏秉铂',
    role: '财务',
    email: 'su@example.com',
    status: '停用',
    createdAt: '2026-04-08 下午8:02',
    lastLogin: '2026-05-29 下午3:20',
  },
];

const initialProducts = [
  {
    id: 101,
    name: '外贸女装连衣裙',
    sku: 'WT-DRESS-001',
    category: '服装',
    warehouse: '广州仓',
    stock: 86,
    status: '库存正常',
    createdAt: '2026-04-12 下午1:45',
  },
  {
    id: 102,
    name: '跨境运动鞋',
    sku: 'WT-SHOES-021',
    category: '鞋履',
    warehouse: '深圳仓',
    stock: 18,
    status: '库存偏低',
    createdAt: '2026-04-08 下午9:26',
  },
  {
    id: 103,
    name: '便携收纳包',
    sku: 'WT-BAG-078',
    category: '箱包',
    warehouse: '义乌仓',
    stock: 0,
    status: '缺货',
    createdAt: '2026-04-08 下午8:02',
  },
  {
    id: 104,
    name: '无线充电器',
    sku: 'WT-CHG-066',
    category: '数码',
    warehouse: '广州仓',
    stock: 42,
    status: '库存正常',
    createdAt: '2026-04-05 下午10:30',
  },
];

const initialReports = [
  {
    id: 'R-20260601',
    type: '销售日报',
    owner: '运营组',
    amount: 32860,
    status: '已生成',
    cycle: '日',
    createdAt: '2026-06-01',
  },
  {
    id: 'R-20260602',
    type: '库存预警',
    owner: '仓储组',
    amount: 18,
    status: '已生成',
    cycle: '日',
    createdAt: '2026-06-02',
  },
  {
    id: 'R-20260603',
    type: '财务汇总',
    owner: '财务组',
    amount: 126,
    status: '待复核',
    cycle: '月',
    createdAt: '2026-06-03',
  },
];

const primaryNav = [
  { key: 'home', label: '首页', icon: <HomeOutlined /> },
  { key: 'products', label: '商品库存', icon: <ProductOutlined /> },
  { key: 'users', label: '用户管理', icon: <UserOutlined /> },
  { key: 'reports', label: '报表查询', icon: <FileTextOutlined /> },
];

const systemNav = [
  { label: '认证模型', icon: <SettingOutlined /> },
  { label: '数据字典', icon: <AppstoreOutlined /> },
  { label: '建表脚本', icon: <ColumnHeightOutlined /> },
];

const productColumns = [
  {
    title: '商品',
    dataIndex: 'name',
    width: 260,
    render: (_, record) => (
      <div>
        <div className="item-name">{record.name}</div>
        <div className="item-sku">{record.sku}</div>
      </div>
    ),
  },
  { title: '分类', dataIndex: 'category', width: 110 },
  { title: '仓库', dataIndex: 'warehouse', width: 120 },
  { title: '库存', dataIndex: 'stock', width: 96, sorter: (a, b) => Number(a.stock) - Number(b.stock) },
  {
    title: '状态',
    dataIndex: 'status',
    width: 120,
    render: (value) => <StatusBadge value={value} />,
  },
  { title: '创建时间', dataIndex: 'createdAt', width: 170 },
];

function normalizeFilterChips(filterChips) {
  return filterChips.map((item) => {
    if (typeof item === 'string') {
      return { key: item, label: item, dataIndex: item };
    }
    return item;
  });
}

function getFilterValueLabel(chip, value) {
  if (!chip?.options) {
    return value;
  }
  return chip.options.find((option) => option.value === value)?.label || value;
}

function matchFilterValue(record, chip, value) {
  if (value === undefined || value === null || value === '') {
    return true;
  }
  const rawValue = record[chip.dataIndex];
  if (chip.type === 'select' || chip.match === 'equals') {
    return String(rawValue) === String(value);
  }
  return String(rawValue ?? '').toLowerCase().includes(String(value).toLowerCase());
}

function StatusBadge({ value }) {
  const className = value === '缺货' || value === '停用'
    ? 'badge badge-out-stock'
    : value === '库存偏低' || value === '待复核'
      ? 'badge badge-low-stock'
      : 'badge badge-in-stock';
  return <span className={className}>{value}</span>;
}

function LoginPage({ onLogin }) {
  return (
    <main className="login-page">
      <section className="card login-card">
        <div className="workspace-avatar">外</div>
        <Title level={2}>外贸通电商智控系统</Title>
        <Text type="secondary">数据库大作业前台模板</Text>
        <Form layout="vertical" className="login-form" onFinish={onLogin} initialValues={{ username: 'admin' }}>
          <Form.Item label="账号" name="username" rules={[{ required: true, message: '请输入账号' }]}>
            <Input placeholder="admin" />
          </Form.Item>
          <Form.Item label="密码" name="password" rules={[{ required: true, message: '请输入密码' }]}>
            <Input.Password placeholder="任意密码" />
          </Form.Item>
          <Button className="btn btn-primary" htmlType="submit" block>
            登录系统
          </Button>
        </Form>
      </section>
    </main>
  );
}

function Sidebar({ activeKey, onChange }) {
  return (
    <aside className="sidebar">
      <div className="workspace-switcher">
        <div className="workspace-avatar">外</div>
        <span>外贸通</span>
        <span className="workspace-caret">⌄</span>
      </div>

      <div className="sidebar-label">工作台</div>
      <nav className="sidebar-section">
        {primaryNav.map((item) => (
          <button
            type="button"
            key={item.key}
            className={`sidebar-item ${activeKey === item.key ? 'active' : ''}`}
            onClick={() => onChange(item.key)}
          >
            {item.icon}
            <span>{item.label}</span>
          </button>
        ))}
      </nav>

      <div className="sidebar-label">系统设计</div>
      <nav className="sidebar-section">
        {systemNav.map((item) => (
          <button type="button" className="sidebar-item muted" key={item.label}>
            {item.icon}
            <span>{item.label}</span>
          </button>
        ))}
      </nav>

      <div className="sidebar-bottom">
        <span>数据库大作业</span>
      </div>
    </aside>
  );
}

function Topbar() {
  return (
    <header className="topbar">
      <div className="search-box">
        <SearchOutlined />
        <span>搜索商品、用户、报表</span>
      </div>
      <div className="topbar-actions">
        <AppstoreOutlined />
        <BellOutlined />
        <SettingOutlined />
        <PlusOutlined className="accent-icon" />
      </div>
    </header>
  );
}

function DashboardHome({ products }) {
  const lowStockCount = products.filter((item) => item.status !== '库存正常').length;
  const overviewCards = [
    { title: '销售额', value: '¥32,860.00', meta: '较上一周期 +12.4%', kind: 'line' },
    { title: '库存预警', value: lowStockCount, meta: `${products.length} 个商品正在监控`, kind: 'empty' },
    { title: '报表快照', value: initialReports.length, meta: '已保存查询模型', kind: 'flat' },
    { title: '系统用户', value: initialUsers.length, meta: '含管理员、运营、财务', kind: 'dotted' },
  ];

  return (
    <>
      <section className="today-section">
        <div className="section-head">
          <h1>今天</h1>
          <button type="button" className="small-outline">刷新</button>
        </div>
        <div className="today-grid">
          <div className="today-main">
            <div className="money-row">
              <div>
                <button type="button" className="metric-select">销售额<DownOutlined /></button>
                <strong>¥32,860.00</strong>
                <span>下午1:59</span>
              </div>
              <div>
                <button type="button" className="metric-select">昨日<DownOutlined /></button>
                <strong>¥28,640.00</strong>
              </div>
            </div>
            <div className="timeline">
              <span>上午12:00</span>
              <div className="timeline-line" />
              <span>下午12:00</span>
            </div>
            <div className="balance-row">
              <div>
                <button type="button" className="metric-select">库存金额<DownOutlined /></button>
                <strong>¥96,420.00</strong>
              </div>
              <a>查看明细</a>
            </div>
          </div>
          <aside className="recommend-card">
            <button type="button" className="close-button"><CloseOutlined /></button>
            <h3>待处理事项</h3>
            <p>3 个低库存商品需要补货复核。</p>
            <a>查看库存</a>
            <p>1 份财务汇总报表等待确认。</p>
            <a>进入报表</a>
            <div className="api-box">
              <div>
                <strong>后端状态</strong>
                <a>认证接口</a>
              </div>
              <p><span>JWT</span><code>/api/token/</code></p>
              <p><span>用户</span><code>/api/auth/register/</code></p>
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
              <span>每天<DownOutlined /></span>
              <span>对比&nbsp;&nbsp;上一期<DownOutlined /></span>
            </div>
          </div>
          <Space>
            <button type="button" className="small-outline">添加</button>
            <button type="button" className="small-outline">编辑</button>
          </Space>
        </div>
        <div className="overview-grid compact-overview">
          {overviewCards.map((card) => (
            <div className="overview-card" key={card.title}>
              <div className="card-title-row">
                <span>{card.title}</span>
                <button type="button">•••</button>
              </div>
              <strong>{card.value}</strong>
              <p>{card.meta}</p>
              <div className={`chart-placeholder ${card.kind}`}>
                {card.kind === 'empty' ? <span>无数据</span> : null}
              </div>
            </div>
          ))}
        </div>
      </section>
    </>
  );
}

function DataListPage({
  title,
  createLabel,
  data,
  setData,
  columns,
  fields,
  createRecord,
  segments,
  filterChips,
  notice,
}) {
  const { message } = App.useApp();
  const [keyword, setKeyword] = useState('');
  const [activeSegment, setActiveSegment] = useState(segments[0]?.key || 'all');
  const [fieldFilters, setFieldFilters] = useState({});
  const [filterModal, setFilterModal] = useState(null);
  const [editing, setEditing] = useState(null);
  const [viewing, setViewing] = useState(null);
  const [form] = Form.useForm();
  const [filterForm] = Form.useForm();

  const filterOptions = useMemo(() => normalizeFilterChips(filterChips), [filterChips]);
  const activeFilterEntries = filterOptions.filter((chip) => fieldFilters[chip.key]);

  const filteredData = useMemo(() => {
    const segment = segments.find((item) => item.key === activeSegment);
    const text = keyword.trim();
    return data
      .filter((item) => (segment?.filter ? segment.filter(item) : true))
      .filter((item) => filterOptions.every((chip) => matchFilterValue(item, chip, fieldFilters[chip.key])))
      .filter((item) => {
        if (!text) return true;
        return Object.values(item).some((value) => String(value).includes(text));
      });
  }, [activeSegment, data, fieldFilters, filterOptions, keyword, segments]);

  const openCreate = () => {
    setEditing({});
    form.resetFields();
  };

  const openEdit = (record) => {
    setEditing(record);
    form.setFieldsValue(record);
  };

  const openFilter = (chip, mode = 'single') => {
    const target = chip || filterOptions[0];
    setFilterModal({ mode, chip: target });
    filterForm.setFieldsValue({
      fieldKey: target.key,
      value: fieldFilters[target.key] || undefined,
    });
  };

  const changeAdvancedFilterField = (fieldKey) => {
    const nextChip = filterOptions.find((chip) => chip.key === fieldKey) || filterOptions[0];
    setFilterModal((current) => ({ ...(current || {}), chip: nextChip }));
    filterForm.setFieldsValue({
      fieldKey,
      value: fieldFilters[fieldKey] || undefined,
    });
  };

  const applyFilter = async () => {
    const values = await filterForm.validateFields();
    const fieldKey = values.fieldKey || filterModal?.chip?.key;
    const chip = filterOptions.find((item) => item.key === fieldKey);
    const value = values.value;
    setFieldFilters((current) => {
      const next = { ...current };
      if (value === undefined || value === null || value === '') {
        delete next[fieldKey];
      } else {
        next[fieldKey] = value;
      }
      return next;
    });
    setFilterModal(null);
    message.success(chip ? `已筛选${chip.label}` : '已筛选');
  };

  const clearFilter = (fieldKey) => {
    setFieldFilters((current) => {
      const next = { ...current };
      delete next[fieldKey];
      return next;
    });
  };

  const clearAllFilters = () => {
    setFieldFilters({});
    setKeyword('');
  };

  const renderFilterControl = (chip) => {
    if (!chip) return null;
    if (chip.type === 'select') {
      return <Select placeholder={`请选择${chip.label}`} options={chip.options} allowClear />;
    }
    return <Input placeholder={`请输入${chip.label}`} allowClear />;
  };

  const saveRecord = async () => {
    const values = await form.validateFields();
    if (editing?.id) {
      setData((items) => items.map((item) => (item.id === editing.id ? { ...item, ...values } : item)));
      message.success('已更新');
    } else {
      setData((items) => [{ ...createRecord(values), ...values }, ...items]);
      message.success('已新增');
    }
    setEditing(null);
  };

  const deleteRecord = (record) => {
    Modal.confirm({
      title: `确认删除 ${record.name || record.id}？`,
      okText: '删除',
      cancelText: '取消',
      okButtonProps: { danger: true },
      onOk: () => {
        setData((items) => items.filter((item) => item.id !== record.id));
        message.success('已删除');
      },
    });
  };

  const tableColumns = [
    ...columns,
    {
      title: '',
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

  return (
    <section className="list-page">
      <div className="list-page-head">
        <h1>{title}</h1>
        <Button className="btn btn-primary action-primary" icon={<PlusOutlined />} onClick={openCreate}>
          {createLabel}
        </Button>
      </div>

      <div className="notice-bar">
        <BulbOutlined />
        <span className="notice-copy">{notice}</span>
        <a>开始检查</a>
        <strong><ClockCircleOutlined /> 5 分钟</strong>
        <button type="button"><CloseOutlined /></button>
      </div>

      <div className="segment-row">
        {segments.map((item) => (
          <button
            type="button"
            key={item.key}
            className={`segment-tab ${activeSegment === item.key ? 'active' : ''}`}
            onClick={() => setActiveSegment(item.key)}
          >
            {item.label}
          </button>
        ))}
      </div>

      <div className="list-tools">
        <div className="chip-row">
          {filterOptions.map((item) => (
            <button
              type="button"
              className={`filter-chip ${fieldFilters[item.key] ? 'active' : ''}`}
              key={item.key}
              onClick={() => openFilter(item)}
            >
              <PlusOutlined /> {item.label}
            </button>
          ))}
          <button type="button" className="filter-chip" onClick={() => openFilter(null, 'advanced')}>
            <FilterOutlined /> 更多筛选
          </button>
          <Input
            className="inline-search"
            placeholder={`查询${title}`}
            value={keyword}
            onChange={(event) => setKeyword(event.target.value)}
            allowClear
          />
        </div>
        <div className="table-tool-row">
          <button type="button" className="tool-button"><CopyOutlined />复制</button>
          <button type="button" className="tool-button"><ExportOutlined />导出</button>
          <button type="button" className="tool-button"><BarChartOutlined />分析</button>
          <button type="button" className="tool-button"><SettingOutlined />编辑列</button>
        </div>
      </div>

      {activeFilterEntries.length > 0 ? (
        <div className="active-filter-row">
          {activeFilterEntries.map((chip) => (
            <button type="button" className="active-filter-pill" key={chip.key} onClick={() => openFilter(chip)}>
              {chip.label}: {getFilterValueLabel(chip, fieldFilters[chip.key])}
              <CloseOutlined onClick={(event) => {
                event.stopPropagation();
                clearFilter(chip.key);
              }} />
            </button>
          ))}
          <button type="button" className="clear-filter-button" onClick={clearAllFilters}>清除筛选</button>
        </div>
      ) : null}

      <div className="stripe-table-wrap">
        <Table
          className="stripe-data-table"
          rowKey="id"
          rowSelection={{ columnWidth: 44 }}
          pagination={false}
          dataSource={filteredData}
          columns={tableColumns}
        />
      </div>
      <div className="item-count">{filteredData.length} 项</div>

      <Modal
        title={editing?.id ? `编辑${title}` : createLabel}
        open={!!editing}
        okText="保存"
        cancelText="取消"
        onOk={saveRecord}
        onCancel={() => setEditing(null)}
        destroyOnHidden
        forceRender
      >
        <Form form={form} layout="vertical">
          {fields.map((field) => (
            <Form.Item key={field.name} label={field.label} name={field.name} rules={field.rules}>
              {field.render ? field.render() : <Input placeholder={`请输入${field.label}`} />}
            </Form.Item>
          ))}
        </Form>
      </Modal>

      <Modal title={`${title}详情`} open={!!viewing} footer={null} onCancel={() => setViewing(null)}>
        <div className="detail-list">
          {viewing && Object.entries(viewing).map(([key, value]) => (
            <div className="detail-row" key={key}>
              <span>{key}</span>
              <strong>{String(value)}</strong>
            </div>
          ))}
        </div>
      </Modal>

      <Modal
        title={`筛选${title}`}
        open={!!filterModal}
        okText="应用筛选"
        cancelText="取消"
        onOk={applyFilter}
        onCancel={() => setFilterModal(null)}
        destroyOnHidden
      >
        <Form form={filterForm} layout="vertical">
          {filterModal?.mode === 'advanced' ? (
            <Form.Item label="筛选字段" name="fieldKey" rules={[{ required: true, message: '请选择筛选字段' }]}>
              <Select
                options={filterOptions.map((chip) => ({ label: chip.label, value: chip.key }))}
                onChange={changeAdvancedFilterField}
              />
            </Form.Item>
          ) : null}
          <Form.Item label={filterModal?.chip?.label || '筛选值'} name="value">
            {renderFilterControl(filterModal?.chip)}
          </Form.Item>
        </Form>
      </Modal>
    </section>
  );
}

function ProductPage({ products, setProducts }) {
  return (
    <DataListPage
      title="商品库存"
      createLabel="新增商品"
      data={products}
      setData={setProducts}
      createRecord={() => ({ id: Date.now(), createdAt: '2026-06-03' })}
      columns={productColumns}
      segments={[
        { key: 'all', label: '全部', filter: () => true },
        { key: 'normal', label: '库存正常', filter: (item) => item.status === '库存正常' },
        { key: 'low', label: '库存偏低', filter: (item) => item.status === '库存偏低' },
        { key: 'empty', label: '缺货', filter: (item) => item.status === '缺货' },
        { key: 'focus', label: '重点 SKU', filter: (item) => Number(item.stock) <= 20 },
      ]}
      filterChips={[
        { key: 'sku', label: 'SKU', dataIndex: 'sku' },
        { key: 'name', label: '商品名称', dataIndex: 'name' },
        {
          key: 'warehouse',
          label: '仓库',
          dataIndex: 'warehouse',
          type: 'select',
          options: [
            { label: '广州仓', value: '广州仓' },
            { label: '深圳仓', value: '深圳仓' },
            { label: '义乌仓', value: '义乌仓' },
          ],
        },
        {
          key: 'status',
          label: '状态',
          dataIndex: 'status',
          type: 'select',
          options: [
            { label: '库存正常', value: '库存正常' },
            { label: '库存偏低', value: '库存偏低' },
            { label: '缺货', value: '缺货' },
          ],
        },
      ]}
      notice="当前库存列表已加载外贸通样例数据，低库存与缺货条目已进入预警范围。"
      fields={[
        { label: '商品名称', name: 'name', rules: [{ required: true, message: '请输入商品名称' }] },
        { label: 'SKU', name: 'sku', rules: [{ required: true, message: '请输入 SKU' }] },
        { label: '分类', name: 'category', rules: [{ required: true, message: '请输入分类' }] },
        { label: '仓库', name: 'warehouse', rules: [{ required: true, message: '请输入仓库' }] },
        { label: '库存', name: 'stock', rules: [{ required: true, message: '请输入库存' }] },
        {
          label: '状态',
          name: 'status',
          rules: [{ required: true, message: '请选择状态' }],
          render: () => (
            <Select
              options={[
                { label: '库存正常', value: '库存正常' },
                { label: '库存偏低', value: '库存偏低' },
                { label: '缺货', value: '缺货' },
              ]}
            />
          ),
        },
      ]}
    />
  );
}

function UserPage({ users, setUsers }) {
  return (
    <DataListPage
      title="用户管理"
      createLabel="新增用户"
      data={users}
      setData={setUsers}
      createRecord={() => ({ id: Date.now(), createdAt: '2026-06-03', lastLogin: '-' })}
      columns={[
        {
          title: '用户',
          dataIndex: 'name',
          width: 136,
          render: (value) => <span className="item-name">{value}</span>,
        },
        { title: '邮箱地址', dataIndex: 'email', width: 190 },
        { title: '角色', dataIndex: 'role', width: 88 },
        {
          title: '状态',
          dataIndex: 'status',
          width: 86,
          render: (value) => <StatusBadge value={value} />,
        },
        { title: '创建时间', dataIndex: 'createdAt', width: 150 },
        { title: '最后登录', dataIndex: 'lastLogin', width: 150 },
      ]}
      segments={[
        { key: 'all', label: '全部', filter: () => true },
        { key: 'admin', label: '管理员', filter: (item) => item.role === '管理员' },
        { key: 'ops', label: '运营', filter: (item) => item.role === '运营' },
        { key: 'finance', label: '财务', filter: (item) => item.role === '财务' },
        { key: 'disabled', label: '已停用', filter: (item) => item.status === '停用' },
      ]}
      filterChips={[
        { key: 'email', label: '邮箱地址', dataIndex: 'email' },
        { key: 'name', label: '名称', dataIndex: 'name' },
        {
          key: 'role',
          label: '角色',
          dataIndex: 'role',
          type: 'select',
          options: [
            { label: '管理员', value: '管理员' },
            { label: '运营', value: '运营' },
            { label: '财务', value: '财务' },
          ],
        },
        { key: 'createdAt', label: '创建日期', dataIndex: 'createdAt' },
      ]}
      notice="用户数据用于登录认证、角色权限和后台操作留痕。"
      fields={[
        { label: '姓名', name: 'name', rules: [{ required: true, message: '请输入姓名' }] },
        { label: '邮箱', name: 'email', rules: [{ required: true, message: '请输入邮箱' }] },
        {
          label: '角色',
          name: 'role',
          rules: [{ required: true, message: '请选择角色' }],
          render: () => (
            <Select
              options={[
                { label: '管理员', value: '管理员' },
                { label: '运营', value: '运营' },
                { label: '财务', value: '财务' },
              ]}
            />
          ),
        },
        {
          label: '状态',
          name: 'status',
          rules: [{ required: true, message: '请选择状态' }],
          render: () => (
            <Select
              options={[
                { label: '启用', value: '启用' },
                { label: '停用', value: '停用' },
              ]}
            />
          ),
        },
      ]}
    />
  );
}

function ReportPage({ reports, setReports }) {
  return (
    <section className="report-page">
      <div className="report-range">
        <RangePicker />
      </div>
      <DataListPage
        title="报表查询"
        createLabel="新增报表"
        data={reports}
        setData={setReports}
        createRecord={() => ({ id: `R-${Date.now()}` })}
        columns={[
          { title: '报表编号', dataIndex: 'id', width: 170 },
          { title: '类型', dataIndex: 'type', width: 130 },
          { title: '负责人', dataIndex: 'owner', width: 120 },
          { title: '周期', dataIndex: 'cycle', width: 90 },
          { title: '统计值', dataIndex: 'amount', width: 120, sorter: (a, b) => Number(a.amount) - Number(b.amount) },
          {
            title: '状态',
            dataIndex: 'status',
            width: 110,
            render: (value) => <StatusBadge value={value} />,
          },
          { title: '创建日期', dataIndex: 'createdAt', width: 130 },
        ]}
        segments={[
          { key: 'all', label: '全部', filter: () => true },
          { key: 'sales', label: '销售日报', filter: (item) => item.type === '销售日报' },
          { key: 'stock', label: '库存预警', filter: (item) => item.type === '库存预警' },
          { key: 'finance', label: '财务汇总', filter: (item) => item.type === '财务汇总' },
          { key: 'review', label: '待复核', filter: (item) => item.status === '待复核' },
        ]}
        filterChips={[
          { key: 'id', label: '报表编号', dataIndex: 'id' },
          {
            key: 'type',
            label: '类型',
            dataIndex: 'type',
            type: 'select',
            options: [
              { label: '销售日报', value: '销售日报' },
              { label: '库存预警', value: '库存预警' },
              { label: '财务汇总', value: '财务汇总' },
            ],
          },
          { key: 'owner', label: '负责人', dataIndex: 'owner' },
          { key: 'createdAt', label: '创建日期', dataIndex: 'createdAt' },
        ]}
        notice="报表查询模型覆盖销售、库存和财务汇总，便于答辩展示查询与统计能力。"
        fields={[
          { label: '报表类型', name: 'type', rules: [{ required: true, message: '请输入报表类型' }] },
          { label: '负责人', name: 'owner', rules: [{ required: true, message: '请输入负责人' }] },
          { label: '周期', name: 'cycle', rules: [{ required: true, message: '请输入周期' }] },
          { label: '统计值', name: 'amount', rules: [{ required: true, message: '请输入统计值' }] },
          {
            label: '状态',
            name: 'status',
            rules: [{ required: true, message: '请选择状态' }],
            render: () => (
              <Select
                options={[
                  { label: '已生成', value: '已生成' },
                  { label: '待复核', value: '待复核' },
                ]}
              />
            ),
          },
          { label: '日期', name: 'createdAt', rules: [{ required: true, message: '请输入日期' }] },
        ]}
      />
    </section>
  );
}

export default function RootApp() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [activeSection, setActiveSection] = useState('home');
  const [users, setUsers] = useState(initialUsers);
  const [products, setProducts] = useState(initialProducts);
  const [reports, setReports] = useState(initialReports);

  if (!loggedIn) {
    return (
      <App>
        <LoginPage onLogin={() => setLoggedIn(true)} />
      </App>
    );
  }

  const pages = {
    home: <DashboardHome products={products} />,
    products: <ProductPage products={products} setProducts={setProducts} />,
    users: <UserPage users={users} setUsers={setUsers} />,
    reports: <ReportPage reports={reports} setReports={setReports} />,
  };

  return (
    <App>
      <div className="console-shell">
        <Sidebar activeKey={activeSection} onChange={setActiveSection} />
        <Topbar />
        <main className="console-main">
          <div className="content-column">
            {pages[activeSection]}
          </div>
        </main>
        <div className="developer-bar">
          <span>开发人员</span>
          <span>外贸通 · 陈炜嘉 · 邝文涛 · 苏秉铂</span>
        </div>
      </div>
    </App>
  );
}
