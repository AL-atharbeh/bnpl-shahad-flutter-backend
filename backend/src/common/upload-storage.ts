import { BadRequestException } from '@nestjs/common';
import { put } from '@vercel/blob';
import { randomBytes } from 'crypto';
import { existsSync } from 'fs';
import { mkdir, writeFile } from 'fs/promises';
import { basename, extname, join } from 'path';

/**
 * Where uploaded images go. Vercel's filesystem does not persist, so there
 * they go to Vercel Blob. On a server of our own, UPLOAD_STORAGE=disk keeps
 * them in UPLOAD_DIR (a mounted folder) and the API serves them back.
 */
export type UploadFolder = 'products' | 'banners';

const uploadRoot = () => process.env.UPLOAD_DIR || join(process.cwd(), 'uploads');

const useDisk = () => process.env.UPLOAD_STORAGE === 'disk';

/** The file's place on disk, or null for a name that tries to leave the folder. */
export function uploadedFilePath(folder: UploadFolder, filename: string): string | null {
  if (!filename || basename(filename) !== filename || filename.startsWith('.')) {
    return null;
  }
  const path = join(uploadRoot(), folder, filename);
  return existsSync(path) ? path : null;
}

/**
 * Merchant documents (registration, licence, owner ID). Unlike images they
 * get no public URL: they sit in UPLOAD_DIR/documents and are only served
 * through a route that checks the caller is the store or an admin.
 */
const DOCUMENT_TYPES: Record<string, string> = {
  'image/jpeg': '.jpg',
  'image/png': '.png',
  'application/pdf': '.pdf',
};

export function documentContentType(filename: string): string {
  const ext = extname(filename).toLowerCase();
  return Object.keys(DOCUMENT_TYPES).find((k) => DOCUMENT_TYPES[k] === ext) || 'application/octet-stream';
}

export async function storePrivateDocument(file: Express.Multer.File): Promise<string> {
  const ext = DOCUMENT_TYPES[file.mimetype];
  if (!ext) {
    throw new BadRequestException('Only JPG, PNG or PDF documents are allowed.');
  }
  if (process.env.UPLOAD_STORAGE !== 'disk') {
    throw new BadRequestException('Document uploads need UPLOAD_STORAGE=disk.');
  }
  const dir = join(uploadRoot(), 'documents');
  await mkdir(dir, { recursive: true });
  const filename = `${Date.now()}-${randomBytes(12).toString('hex')}${ext}`;
  await writeFile(join(dir, filename), file.buffer);
  return filename;
}

/** The document's place on disk, or null for a missing or crafted name. */
export function privateDocumentPath(filename: string): string | null {
  if (!filename || basename(filename) !== filename || filename.startsWith('.')) return null;
  const path = join(uploadRoot(), 'documents', filename);
  return existsSync(path) ? path : null;
}

/** Stores the image and returns its public URL. */
export async function storeUpload(
  folder: UploadFolder,
  file: Express.Multer.File,
): Promise<{ url: string; filename: string }> {
  // The client's name is only a hint: keep its extension, nothing it could
  // use to climb out of the folder.
  const ext = extname(file.originalname).toLowerCase().replace(/[^a-z0-9.]/g, '');
  const filename = `${Date.now()}-${randomBytes(6).toString('hex')}${ext}`;

  if (useDisk()) {
    const dir = join(uploadRoot(), folder);
    await mkdir(dir, { recursive: true });
    await writeFile(join(dir, filename), file.buffer);

    const base = (process.env.PUBLIC_URL || '').replace(/\/+$/, '');
    const prefix = process.env.API_PREFIX || 'api/v1';
    return { url: `${base}/${prefix}/${folder}/uploads/${filename}`, filename };
  }

  if (!process.env.BLOB_READ_WRITE_TOKEN) {
    throw new BadRequestException(
      'Image uploads are not configured: set BLOB_READ_WRITE_TOKEN, or UPLOAD_STORAGE=disk.',
    );
  }

  const blob = await put(`${folder}/${filename}`, file.buffer, {
    access: 'public',
    addRandomSuffix: true,
  });
  return { url: blob.url, filename };
}
