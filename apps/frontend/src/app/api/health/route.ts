import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const backendUrl = process.env.BACKEND_INTERNAL_URL || 'http://localhost:3000';
    const res = await fetch(`${backendUrl}/`);
    const data = await res.json();
    return NextResponse.json({ status: 'ok', backend: data });
  } catch {
    return NextResponse.json({ status: 'ok', backend: { status: 'unreachable' } });
  }
}
