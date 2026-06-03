import { useMemo, useState } from 'react';
import {
  BarChartOutlined,
  DatabaseOutlined,
  HomeOutlined,
  LockOutlined,
  LogoutOutlined,
  PlusOutlined,
  SearchOutlined,
  ShopOutlined,
  UserOutlined,
} from '@ant-design/icons';
import {
  Avatar,
  Button,
  Card,
  Col,
  DatePicker,
  Divider,
  Form,
  Input,
  Layout,
  Menu,
  Modal,
  Row,
  Select,
  Space,
  Statistic,
  Table,
  Tag,
  Typography,
  message,
} from 'antd';

const { Header, Sider, Content } = Layout;
const { Title, Text } = Typography;
const { RangePicker } = DatePicker;

const initialUsers = [
  { id: 1, name: '张晴', role: '管理员', email: 'zhangqing@example.com', status: '启用' },
  { id: 2, name: '李明', role: '运营', email: 'liming@example.com', status: '启用' },
  { id: 3, name: '王佳', role: '访客', email: 'wangjia@example.com', status: '停用' },
];

const initialProducts = [
  { id: 101, name: '无线键盘', category: '数码配件', price: 169, stock: 86, status: '上架' },
  { id: 102, name: '便携水杯', category: '生活用品', price: 49, stock: 214, status: '上架' },
  { id: 103, name: '学习台灯', category: '办公学习', price: 129, stock: 37, status: '下架' },
];

const initialReports = [
  { id: 'R-20260601', type: '销售日报', owner: '运营组', amount: 32860, createdAt: '2026-06-01' },
  { id: 'R-20260602', type: '库存预警', owner: '仓储组', amount: 18, createdAt: '2026-06-02' },
  { id: 'R-20260603', type: '用户增长', owner: '管理员', amount: 126, createdAt: '2026-06-03' },
];

const menuItems = [
  { key: 'dashboard', icon: <HomeOutlined />, label: '首页概览' },
  { key: 'users', icon: <UserOutlined />, label: '用户管理' },
  { key: 'products', icon: <ShopOutlined />, label: '商品管理' },
  { key: 'reports', icon: <BarChartOutlined />, label: '报表查询' },
];

function LoginPage({ onLogin }) {
  return (
    <main className="login-shell">
      <section className="login-panel">
        <div className="brand-mark">
          <DatabaseOutlined />
        </div>
        <Title level={2}>外贸通电商智控系统</Title>
        <Text type="secondary">使用简化模板演示后台系统登录、导航、管理与查询流程。</Text>
        <Form layout="vertical" className="login-form" onFinish={onLogin} initialValues={{ username: 'admin' }}>
          <Form.Item label="账号" name="username" rules={[{ required: true, message: '请输入账号' }]}>
            <Input prefix={<UserOutlined />} placeholder="admin" />
          </Form.Item>
          <Form.Item label="密码" name="password" rules={[{ required: true, message: '请输入密码' }]}>
            <Input.Password prefix={<LockOutlined />} placeholder="任意密码" />
          </Form.Item>
          <Button type="primary" htmlType="submit" block>
            登录系统
          </Button>
        </Form>
      </section>
    </main>
  );
}

function Dashboard() {
  const metrics = [
    { title: '用户总数', value: 1286, suffix: '人', color: 'blue' },
    { title: '商品总数', value: 342, suffix: '件', color: 'purple' },
    { title: '今日订单', value: 96, suffix: '单', color: 'cyan' },
    { title: '报表数量', value: 28, suffix: '份', color: 'gold' },
  ];

  return (
    <Space direction="vertical" size={18} className="page-stack">
      <section className="hero-strip">
        <div>
          <Text className="eyebrow">FOREIGN TRADE OPERATIONS</Text>
          <Title level={2}>外贸通后台管理模板</Title>
          <Text>面向《数据库原理与应用》课程作业，展示基础数据管理、认证入口和报表查询界面。</Text>
        </div>
        <Button type="primary" icon={<PlusOutlined />}>
          新建记录
        </Button>
      </section>

      <Row gutter={[16, 16]}>
        {metrics.map((item) => (
          <Col xs={24} sm={12} lg={6} key={item.title}>
            <Card className={`metric-card accent-${item.color}`}>
              <Statistic title={item.title} value={item.value} suffix={item.suffix} />
            </Card>
          </Col>
        ))}
      </Row>

      <Row gutter={[16, 16]}>
        <Col xs={24} lg={15}>
          <Card title="近期操作" className="clean-card">
            <Table
              rowKey="id"
              pagination={false}
              size="middle"
              dataSource={initialReports}
              columns={[
                { title: '编号', dataIndex: 'id' },
                { title: '类型', dataIndex: 'type' },
                { title: '负责人', dataIndex: 'owner' },
                { title: '日期', dataIndex: 'createdAt' },
              ]}
            />
          </Card>
        </Col>
        <Col xs={24} lg={9}>
          <Card title="系统状态" className="clean-card">
            <Space direction="vertical" size={14} className="wide">
              <StatusLine label="数据库连接" value="正常" color="green" />
              <StatusLine label="接口服务" value="运行中" color="blue" />
              <StatusLine label="数据同步" value="模拟数据" color="purple" />
              <Divider />
              <Text type="secondary">当前模板使用前端 mock 数据，适合后续对接数据库课程后端接口。</Text>
            </Space>
          </Card>
        </Col>
      </Row>
    </Space>
  );
}

function StatusLine({ label, value, color }) {
  return (
    <div className="status-line">
      <Text>{label}</Text>
      <Tag color={color}>{value}</Tag>
    </div>
  );
}

function CrudTable({ title, description, data, setData, columns, fields, createRecord }) {
  const [open, setOpen] = useState(false);
  const [viewing, setViewing] = useState(null);
  const [editing, setEditing] = useState(null);
  const [keyword, setKeyword] = useState('');
  const [form] = Form.useForm();

  const filteredData = useMemo(() => {
    const text = keyword.trim();
    if (!text) return data;
    return data.filter((item) => Object.values(item).some((value) => String(value).includes(text)));
  }, [data, keyword]);

  const handleCreate = () => {
    setEditing(null);
    form.resetFields();
    setOpen(true);
  };

  const handleView = (record) => {
    setViewing(record);
  };

  const handleEdit = (record) => {
    setEditing(record);
    form.setFieldsValue(record);
    setOpen(true);
  };

  const handleDelete = (record) => {
    Modal.confirm({
      title: `确认删除 ${record.name || record.id}？`,
      okText: '删除',
      okButtonProps: { danger: true },
      cancelText: '取消',
      onOk: () => {
        setData((items) => items.filter((item) => item.id !== record.id));
        message.success('已删除');
      },
    });
  };

  const handleSubmit = async () => {
    const values = await form.validateFields();
    if (editing) {
      setData((items) => items.map((item) => (item.id === editing.id ? { ...item, ...values } : item)));
      message.success('已更新');
    } else {
      setData((items) => [{ ...createRecord(values), ...values }, ...items]);
      message.success('已新增');
    }
    setOpen(false);
  };

  return (
    <Space direction="vertical" size={18} className="page-stack">
      <section className="page-heading">
        <div>
          <Title level={3}>{title}</Title>
          <Text type="secondary">{description}</Text>
        </div>
        <Button type="primary" icon={<PlusOutlined />} onClick={handleCreate}>
          新增
        </Button>
      </section>
      <Card className="clean-card">
        <Space wrap className="toolbar">
          <Input
            allowClear
            prefix={<SearchOutlined />}
            placeholder={`查询${title}`}
            value={keyword}
            onChange={(event) => setKeyword(event.target.value)}
            className="search-input"
          />
          <Button icon={<SearchOutlined />}>查询</Button>
          <Button onClick={() => setKeyword('')}>重置</Button>
        </Space>
        <Table
          rowKey="id"
          dataSource={filteredData}
          columns={[
            ...columns,
            {
              title: '操作',
              key: 'actions',
              width: 230,
              render: (_, record) => (
                <Space>
                  <Button onClick={() => handleView(record)}>查看</Button>
                  <Button onClick={() => handleEdit(record)}>编辑</Button>
                  <Button danger onClick={() => handleDelete(record)}>
                    删除
                  </Button>
                </Space>
              ),
            },
          ]}
        />
      </Card>
      <Modal
        title={editing ? `编辑${title}` : `新增${title}`}
        open={open}
        okText="保存"
        cancelText="取消"
        onCancel={() => setOpen(false)}
        onOk={handleSubmit}
        destroyOnHidden
      >
        <Form form={form} layout="vertical" className="modal-form">
          {fields.map((field) => (
            <Form.Item key={field.name} label={field.label} name={field.name} rules={field.rules}>
              {field.render ? field.render() : <Input placeholder={`请输入${field.label}`} />}
            </Form.Item>
          ))}
        </Form>
      </Modal>
      <Modal title={`${title}详情`} open={!!viewing} footer={null} onCancel={() => setViewing(null)}>
        <div className="detail-list">
          {viewing &&
            columns
              .filter((column) => column.dataIndex)
              .map((column) => (
                <div className="detail-row" key={column.dataIndex}>
                  <Text type="secondary">{column.title}</Text>
                  <Text strong>{String(viewing[column.dataIndex] ?? '-')}</Text>
                </div>
              ))}
        </div>
      </Modal>
    </Space>
  );
}

function ReportsPage({ reports, setReports }) {
  const [keyword, setKeyword] = useState('');
  const filteredReports = useMemo(() => {
    const text = keyword.trim();
    if (!text) return reports;
    return reports.filter((item) => Object.values(item).some((value) => String(value).includes(text)));
  }, [keyword, reports]);

  return (
    <Space direction="vertical" size={18} className="page-stack">
      <section className="page-heading">
        <div>
          <Title level={3}>报表查询</Title>
          <Text type="secondary">支持按关键字和日期范围筛选 mock 报表，并通过弹窗维护报表记录。</Text>
        </div>
      </section>
      <Card className="clean-card">
        <Space wrap className="toolbar">
          <Input
            allowClear
            prefix={<SearchOutlined />}
            placeholder="搜索编号、类型或负责人"
            value={keyword}
            onChange={(event) => setKeyword(event.target.value)}
            className="search-input"
          />
          <RangePicker />
        </Space>
      </Card>
      <CrudTable
        title="报表"
        description="报表记录维护采用按钮加弹窗交互。"
        data={filteredReports}
        setData={setReports}
        createRecord={() => ({ id: `R-${Date.now()}` })}
        fields={[
          { label: '报表类型', name: 'type', rules: [{ required: true, message: '请输入报表类型' }] },
          { label: '负责人', name: 'owner', rules: [{ required: true, message: '请输入负责人' }] },
          { label: '统计值', name: 'amount', rules: [{ required: true, message: '请输入统计值' }] },
          { label: '日期', name: 'createdAt', rules: [{ required: true, message: '请输入日期' }] },
        ]}
        columns={[
          { title: '报表编号', dataIndex: 'id' },
          { title: '报表类型', dataIndex: 'type' },
          { title: '负责人', dataIndex: 'owner' },
          { title: '统计值', dataIndex: 'amount' },
          { title: '日期', dataIndex: 'createdAt' },
        ]}
      />
    </Space>
  );
}

export default function App() {
  const [loggedIn, setLoggedIn] = useState(false);
  const [activeKey, setActiveKey] = useState('dashboard');
  const [users, setUsers] = useState(initialUsers);
  const [products, setProducts] = useState(initialProducts);
  const [reports, setReports] = useState(initialReports);

  if (!loggedIn) {
    return <LoginPage onLogin={() => setLoggedIn(true)} />;
  }

  const pages = {
    dashboard: <Dashboard />,
    users: (
      <CrudTable
        title="用户管理"
        description="维护系统账号、角色与启停状态。"
        data={users}
        setData={setUsers}
        createRecord={() => ({ id: Date.now() })}
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
                  { label: '访客', value: '访客' },
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
        columns={[
          { title: '姓名', dataIndex: 'name' },
          { title: '邮箱', dataIndex: 'email' },
          { title: '角色', dataIndex: 'role', render: (value) => <Tag color="geekblue">{value}</Tag> },
          {
            title: '状态',
            dataIndex: 'status',
            render: (value) => <Tag color={value === '启用' ? 'green' : 'default'}>{value}</Tag>,
          },
        ]}
      />
    ),
    products: (
      <CrudTable
        title="商品管理"
        description="维护商品分类、售价、库存与上下架状态。"
        data={products}
        setData={setProducts}
        createRecord={() => ({ id: Date.now() })}
        fields={[
          { label: '商品名称', name: 'name', rules: [{ required: true, message: '请输入商品名称' }] },
          { label: '分类', name: 'category', rules: [{ required: true, message: '请输入分类' }] },
          { label: '价格', name: 'price', rules: [{ required: true, message: '请输入价格' }] },
          { label: '库存', name: 'stock', rules: [{ required: true, message: '请输入库存' }] },
          {
            label: '状态',
            name: 'status',
            rules: [{ required: true, message: '请选择状态' }],
            render: () => (
              <Select
                options={[
                  { label: '上架', value: '上架' },
                  { label: '下架', value: '下架' },
                ]}
              />
            ),
          },
        ]}
        columns={[
          { title: '商品名称', dataIndex: 'name' },
          { title: '分类', dataIndex: 'category' },
          { title: '价格', dataIndex: 'price', render: (value) => `￥${value}` },
          { title: '库存', dataIndex: 'stock' },
          {
            title: '状态',
            dataIndex: 'status',
            render: (value) => <Tag color={value === '上架' ? 'green' : 'orange'}>{value}</Tag>,
          },
        ]}
      />
    ),
    reports: <ReportsPage reports={reports} setReports={setReports} />,
  };

  return (
    <Layout className="app-shell">
      <Sider width={240} breakpoint="lg" collapsedWidth="0" className="sidebar">
        <div className="logo-block">
          <span className="logo-icon">
            <DatabaseOutlined />
          </span>
          <div>
            <strong>外贸通</strong>
            <Text type="secondary">课程作业模板</Text>
          </div>
        </div>
        <Menu mode="inline" selectedKeys={[activeKey]} items={menuItems} onClick={({ key }) => setActiveKey(key)} />
      </Sider>
      <Layout>
        <Header className="topbar">
          <div>
            <Text type="secondary">当前模块</Text>
            <Title level={4}>{menuItems.find((item) => item.key === activeKey)?.label}</Title>
          </div>
          <Space>
            <Avatar className="avatar">A</Avatar>
            <Button icon={<LogoutOutlined />} onClick={() => setLoggedIn(false)}>
              退出
            </Button>
          </Space>
        </Header>
        <Content className="content">{pages[activeKey]}</Content>
      </Layout>
    </Layout>
  );
}
