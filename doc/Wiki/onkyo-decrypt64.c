/*
 *  Onkyo firmware decryptor v2 (c) 2014 - vZ@divideoverflow.com
 * 
 *  version 2:
 *  re-written for more sophisticated parsing, fixing bug with some blocks being missed
 * 
 *  version 1.0:
 *  initial release
 * 
 *  Thanks to Turmio for the only page found on the web dedicated to ONKYO reversing
 *  (https://jkry.org/ouluhack/HackingOnkyo%20TR-NX509)
 *  and to Na Na for providing libupdater.so.
 * 
 * 
 */

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <glob.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/mman.h>
#include <errno.h>

#include <stdlib.h> // atoi

#include <stdint.h>
// these keys were found statically entered in libupdater.so
// however, they aren't usable for every block, hence we'll calculate most of them on demand
// using known-plaintext attack.
uint8_t keyA[8] = "\xda\x57\x68\x0d\x44\x21\x30\x7a";
uint8_t keyB[8] = "\xae\xb7\x31\x74\x47\xe4\xfb\x5d";

uint8_t cryptKey[8] = { 0 };

char plaintext[] = "ONKYO Encryption";
uint32_t Magic1 = 0x57cb4295;

FILE *fp;
char path[4000] = { 0 };
char outname[4000] = { 0 };
char outdir[4000] = { 0 };

uint32_t blocksize = 0x1000;
uint8_t lastkey = 0;
uint32_t counter = 0;
uint8_t dst[0x1000] = { 0 };

int32_t ofnum = 0;

uint32_t
calc_crc (uint8_t *src, uint32_t size)
{
  uint32_t x = 0, y = 0;
  int32_t i = 0;
  uint8_t b1, b2, b3, b4;

  size--;

  do
    {
      b1 = src[i++];
      x = y + b1;
      if (i > size)
    break;
      b2 = src[i++];
      x += b2 << 8;
      if (i > size)
    break;
      b3 = src[i++];
      x += b3 << 16;
      if (i > size)
    break;
      b4 = src[i++];
      x += b4 << 24;
      y = (x << 11) + (x >> 21);
      if (i > size)
    break;

    }
  while (1);

  return x;
}

void
calc_key (uint8_t *src, uint8_t *cryptKey)
{
  uint8_t key[8] = { 0 };
  int32_t n, j, b;
  uint8_t lk = 0;

  lk = plaintext[0] ^ src[0];
  key[0] = lk;

  for (j = 1; j < 8; j++)
    {
      n = lk >> 7;
      b = n;
      lk = lk & 0x7f;
      n = n | (lk << 1);
      lk = plaintext[j] ^ src[j];
      key[j] = lk + 0x100 * b - n;
    }

  memcpy (cryptKey, key, 8);
}

int32_t
match_crc (uint8_t *src, uint32_t size, uint32_t crc)
{
  return (crc == calc_crc (src, size));
}

void
decrypt_block (uint8_t *src, uint8_t *dst, int32_t size,
           uint8_t *xorkey, uint32_t *c, uint8_t *lk)
{
  int32_t n, i = 0, j = 0;
  int32_t k = 0;

  if (size == 0)
    return;

  if (*c == 0)
    *lk = xorkey[0];
  j = *c % 7;

  do
    {

      dst[i] = src[i] ^ *lk;
      n = (*lk >> 7);
      j++;
      k = xorkey[j];
      *lk = *lk & 0x7f;
      n = n | (*lk << 1);
      k = k + n;
      *c = *c + 1;
      k = k + (*c >> 6);
      *lk = k & 0xff;
      if (j == 7)
    j = 0;
      i++;
      size--;

    }
  while (size > 0);

  return;
}

void
make_target_dir ()
{
  struct stat sb;
  int32_t e;

  strcpy (outdir, path);
  strcat (outdir, "/extracted");

  e = stat (outdir, &sb);
  if (e == 0)
    {
      if (!(sb.st_mode & S_IFDIR))
    {
      fprintf (stdout, "Target '%s' must be a directory!\n", outdir);
    }
    }
  else
    {
      if (errno = ENOENT)
    {
      e = mkdir (outdir, S_IRWXU);
      if (e != 0)
        perror ("mkdir failed\n");
    }
    }
}

int32_t
parse_header (uint8_t *src)
{

  typedef struct header
  {
    char sig[0x10];
    uint32_t dataofs;
    uint32_t crc;
    uint32_t pname;
    uint32_t ptree;
    uint32_t precords;
    uint8_t unk1[12];
    char name[0x20];
    char subname[4];
    uint8_t unpackedfiles;
    uint8_t packedfiles;
    uint8_t ofnum;
    uint8_t fileshere;
    uint8_t unk2[0x1a8];
  } __attribute__((packed)) t_header;
  t_header hdr;

  typedef struct block
  {
    char filename[8];
    uint32_t offset;
    uint32_t size;
    uint32_t crc;
  } __attribute__((packed)) t_block;
  t_block blk[20];

  uint8_t *blkptr;
  int32_t result = -1;
  int32_t tb = 0;
  int32_t i, f;
  uint32_t counter = 0;

  decrypt_block (src, dst, sizeof (hdr), keyA, &counter, &lastkey);
  if (memcmp (dst, plaintext, 0x10) != 0)
    return -1;
  memcpy (&hdr, dst, sizeof (hdr));

  if (match_crc
      ((uint8_t *) (&hdr) + 0x18, hdr.dataofs - 0x18, hdr.crc))
    {
      sprintf (outname, "%s/of%i.%s.hdr", outdir, ofnum, hdr.name);
      fp = fopen (outname, "w");
      if (fp)
    {
      fwrite (&hdr, 1, hdr.dataofs, fp);
      fclose (fp);
      fprintf (stdout, "Header block decrypted and saved to %s\n",
           outname);
      result = 1;
    }

      int32_t prec = hdr.precords;
      int32_t frec = hdr.ptree;
      while (prec < hdr.dataofs)
    {
      if (*(uint32_t *) ((uint8_t *) &hdr + prec) != 0
          && *(uint32_t *) ((uint8_t *) &hdr + prec + 4))
        {
          blk[tb].size =
        *(uint32_t *) ((uint8_t *) &hdr + prec);
          blk[tb].offset =
        *(uint32_t *) ((uint8_t *) &hdr + prec + 4);
          blk[tb].crc =
        *(uint32_t *) ((uint8_t *) &hdr + prec + 8);
          strncpy (blk[tb].filename, (char *) ((char *) &hdr + frec + 1),
               7);
          tb++;
        }
      prec += 0x10;
      frec += 8;
    }

      for (i = 0; i < tb; i++)
    {

      blkptr = src + blk[i].offset;
      counter = 0;
      blocksize = 0x1000;

      if (calc_crc (blkptr, blk[i].size) != blk[i].crc)
        {
          fprintf (stdout, "Error: CRC mismatch! Skipping block..\n");
          continue;
        }

      if (*(uint32_t *) (blkptr) == Magic1)
        {
          // process header
          if (parse_header (blkptr) < 0)
        fprintf (stdout, "Error parsing header block!\n");
        }
      else
        {

          // calculate decryption key
          calc_key (blkptr, cryptKey);

          sprintf (outname, "%s/of%i.%s.%s", outdir, ofnum, hdr.name,
               blk[i].filename);
          fprintf (stdout,
               "Writing block from 0x%.8x of size %u to %s\n",
               blk[i].offset, blk[i].size, outname);

          f = 0;

          do
        {
          decrypt_block (blkptr, dst, blocksize, cryptKey, &counter,
                 &lastkey);
          if (counter == blocksize)
            {
              // verify we got it right
              if (memcmp (dst, plaintext, 0x10) != 0)
            {
              fprintf (stdout,
                   "Error: Invalid decryption key/signature .. skipping this block.\n\n");
              break;
            }

              f = 1;
              fp = fopen (outname, "w");
              fwrite (dst + 0x10, 1, blocksize - 0x10, fp);

            }
          else
            {
              fwrite (dst, 1, blocksize, fp);
            }

          blkptr += blocksize;

          if (counter == blk[i].size)
            break;
          if (blk[i].size - counter < blocksize)
            blocksize = blk[i].size - counter;

        }
          while (1);

          if (f)
        {
          fclose (fp);
          fprintf (stdout,
               "Block successfully decrypted and saved.\n");
          result = 1;
        }
        }
    }

    }
  else
    {
      fprintf (stdout, "Error: Header CRC mismatch.. skipping.\n");
    }

  return result;
}

int32_t
main (int argc, char *argv[])
{
  int32_t fd;
  glob_t globbuf;
  struct stat sb;
  uint8_t *p;
  char searchpath[0x4000] = { 0 };
  long long buflen;
  int32_t j;

  fprintf (stdout,
       "Decrypt Onkyo firmware, (c) 2014, <vZ@divideoverflow.com>\n\n");

  if (argc > 1)
    {
      strcpy (path, argv[1]);
    }
  else
    {
      strcpy (path, ".");
    }

  fprintf (stdout, "Searching for firmware '.of' files in '%s' .. ", path);

  strcpy (searchpath, path);
  strcat (searchpath, "/*.of?");
  glob (searchpath, 0, NULL, &globbuf);

  if (globbuf.gl_pathc > 0)
    {
      fprintf (stdout, "%zi files found.\n", globbuf.gl_pathc);
    }
  else
    {
      fprintf (stdout, "no files found.\n");
      return 0;
    }

  make_target_dir ();

  for (j = 0; j < globbuf.gl_pathc; j++)
    {

      fprintf (stdout, "\nProcessing %s..\n", globbuf.gl_pathv[j]);

      ofnum = atoi (globbuf.gl_pathv[j] + strlen (globbuf.gl_pathv[j]) - 1);

      fd = open (globbuf.gl_pathv[j], O_RDWR);
      if (fd == -1)
    {
      perror ("open");
      return 1;
    }
      if (fstat (fd, &sb) == -1)
    {
      perror ("fstat");
      return 1;
    }
      if (!S_ISREG (sb.st_mode))
    {
      fprintf (stdout, "%s is not a file\n", globbuf.gl_pathv[j]);
      return 1;
    }

      buflen = sb.st_size;
      p = mmap (0, buflen, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);

      if (p == MAP_FAILED)
    {
      perror ("mmap");
      return 1;
    }
      if (close (fd) == -1)
    {
      perror ("close");
      return 1;
    }

      if (buflen < blocksize)
    blocksize = buflen;

      if (*(uint32_t *) p != Magic1)
    {
      // of0 special case. the file is useless but just for the sake of completness
      if ((*(uint32_t *) &p[0x10] == Magic1 && blocksize < 512))
        {
          decrypt_block (p + 0x10, dst, blocksize, keyA, &counter,
                 &lastkey);
          sprintf (outname, "%s/of%i", outdir, ofnum);
          fp = fopen (outname, "w");
          fwrite (&dst, 1, blocksize - 0x10, fp);
          fclose (fp);
          fprintf (stdout, ".of0 file decrypted as %s\n", outname);

        }
      else
        {
          perror ("Invalid file format");
        }
    }
      else
    {
      if (parse_header (p) < 0)
        fprintf (stdout, "Error parsing header block!\n");
    }

    _done:
      if (munmap (p, buflen) == -1)
    {
      perror ("munmap");
      return 1;
    }

    }

  globfree (&globbuf);
  fprintf (stdout, "\nDone!\n");

  return 0;
}

