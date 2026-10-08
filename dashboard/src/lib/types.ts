export type Page<T> = { items: T[]; total: number; page: number; page_size: number };

export type Category = {
  id: number;
  slug: string;
  name_ar: string;
  name_en: string;
  image: string | null;
  sort_order: number;
  is_active: boolean;
  product_count: number;
};

export type Banner = {
  id: number;
  title_ar: string;
  title_en: string;
  image: string;
  link: string | null;
  sort_order: number;
  is_active: boolean;
};

export type Badge = { label: string; icon: string };

export type ProductRow = {
  id: number;
  sku: string;
  title_ar: string;
  title_en: string;
  price: number;
  rating: string;
  category_id: number | null;
  category_name: string | null;
  person_tag: string | null;
  occasion_tag: string | null;
  gift_type_tag: string | null;
  budget_tag: string | null;
  delivery_tag: string | null;
  is_latest: boolean;
  is_popular: boolean;
  status: "active" | "hidden";
  cover_image: string | null;
  sold: number;
  favorites: number;
  score: number;
  created_at: string;
};

export type ProductDetail = ProductRow & {
  description_ar: string;
  description_en: string;
  height_label: string | null;
  width_label: string | null;
  care_steps_ar: string[];
  care_steps_en: string[];
  badges: Badge[];
  images: string[];
};

export type OptionKind = "gift-cards" | "wraps" | "addons";

export type BasketOption = {
  id: number;
  code: string;
  title_ar: string;
  title_en: string;
  price: number;
  image: string;
  is_active: boolean;
  category?: string;
};

export type OrderRow = {
  id: number;
  code: string;
  status: string;
  payment_method: string;
  recipient_name: string;
  recipient_phone: string;
  governorate: string | null;
  total: number;
  items_count: number;
  created_at: string;
};

export type OrderDetail = {
  id: number;
  code: string;
  status: string;
  payment_method: string;
  recipient_name: string;
  recipient_phone: string;
  governorate: string | null;
  landmark: string;
  unknown_address: boolean;
  items: {
    product_id: number | null;
    title_ar: string;
    image: string | null;
    unit_price: number;
    qty: number;
    line_total: number;
  }[];
  gift_card: { title_ar?: string; price?: number; image?: string } | null;
  wrap: { title_ar?: string; price?: number; image?: string } | null;
  addons: { title_ar?: string; price?: number; image?: string }[];
  gift_from: string;
  gift_to: string;
  gift_message: string;
  subtotal: number;
  wrap_price: number;
  addons_price: number;
  card_price: number;
  delivery_price: number;
  total: number;
  created_at: string;
  customer: { id: number; name: string; phone: string } | null;
};

export type UserRow = {
  id: number;
  name: string;
  phone: string;
  email: string | null;
  governorate: string | null;
  is_active: boolean;
  is_admin: boolean;
  notifications_enabled: boolean;
  locale: string;
  orders_count: number;
  total_spent: number;
  created_at: string;
};

export type UserDetail = UserRow & {
  orders: OrderRow[];
  favorites_count: number;
  reminders_count: number;
};

export type Stats = {
  orders_total: number;
  orders_today: number;
  orders_pending: number;
  orders_by_status: Record<string, number>;
  revenue_total: number;
  revenue_today: number;
  customers_total: number;
  customers_new_week: number;
  products_total: number;
  products_active: number;
  tickets_open: number;
  favorites_total: number;
  reminders_total: number;
  series: { date: string; orders: number; revenue: number }[];
  recent_orders: OrderRow[];
  top_products: {
    id: number;
    title_ar: string;
    cover_image: string | null;
    price: number;
    sold: number;
    favorites: number;
    score: number;
  }[];
};

export type Broadcast = {
  key: string;
  title_ar: string;
  body_ar: string;
  link: string | null;
  created_at: string;
  recipients: number;
  read: number;
};

export type FaqItem = {
  id: number;
  category_id: number;
  question_ar: string;
  question_en: string;
  answer_ar: string;
  answer_en: string;
  sort_order: number;
};

export type FaqCategory = {
  id: number;
  slug: string;
  title_ar: string;
  title_en: string;
  sort_order: number;
  items: FaqItem[];
};

export type PrivacySection = {
  id: number;
  slug: string;
  title_ar: string;
  title_en: string;
  body_ar: string;
  body_en: string;
  sort_order: number;
  updated_at: string;
};

export type Ticket = {
  id: number;
  user_id: number | null;
  user_name: string | null;
  name: string;
  phone: string;
  subject: string;
  message: string;
  status: "open" | "in_progress" | "closed";
  created_at: string;
  updated_at: string;
};

export type Lookups = {
  governorates: string[];
  person: string[];
  occasion: string[];
  gift_type: string[];
  budget: string[];
  delivery: string[];
  filters: { id: string; title: string; options: { id: string; label: string }[] }[];
  addon_categories: { id: string; label: string }[];
};
