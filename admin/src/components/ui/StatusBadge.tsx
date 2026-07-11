import clsx from 'clsx'

type Status = 'Completed' | 'In Progress' | 'Pending' | 'Cancelled' | 'Active' | 'Inactive' | 'Suspended' | 'Pending Verification' | 'Success' | 'Failed' | 'Refunded' | 'Banned'

const statusConfig: Record<Status, { bg: string; text: string; dot: string }> = {
  'Completed':            { bg: 'bg-green-50',  text: 'text-green-700',  dot: 'bg-green-500' },
  'Active':               { bg: 'bg-green-50',  text: 'text-green-700',  dot: 'bg-green-500' },
  'Success':              { bg: 'bg-green-50',  text: 'text-green-700',  dot: 'bg-green-500' },
  'In Progress':          { bg: 'bg-blue-50',   text: 'text-blue-700',   dot: 'bg-blue-500' },
  'Pending':              { bg: 'bg-amber-50',  text: 'text-amber-700',  dot: 'bg-amber-500' },
  'Pending Verification': { bg: 'bg-amber-50',  text: 'text-amber-700',  dot: 'bg-amber-500' },
  'Cancelled':            { bg: 'bg-red-50',    text: 'text-red-600',    dot: 'bg-red-500' },
  'Inactive':             { bg: 'bg-gray-100',  text: 'text-gray-600',   dot: 'bg-gray-400' },
  'Suspended':            { bg: 'bg-red-50',    text: 'text-red-600',    dot: 'bg-red-500' },
  'Banned':               { bg: 'bg-red-50',    text: 'text-red-600',    dot: 'bg-red-500' },
  'Failed':               { bg: 'bg-red-50',    text: 'text-red-600',    dot: 'bg-red-500' },
  'Refunded':             { bg: 'bg-purple-50', text: 'text-purple-700', dot: 'bg-purple-500' },
}

export default function StatusBadge({ status }: { status: Status }) {
  const cfg = statusConfig[status] ?? { bg: 'bg-gray-100', text: 'text-gray-600', dot: 'bg-gray-400' }
  return (
    <span className={clsx('inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full text-[11px] font-semibold', cfg.bg, cfg.text)}>
      <span className={clsx('w-[6px] h-[6px] rounded-full', cfg.dot)} />
      {status}
    </span>
  )
}
