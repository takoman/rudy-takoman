# Production Environment

- [DigitalOcean](#digitalocearn)
- [Amazon S3](#amazon-s3)
- [CloudFront](#cloudfront)

## DigitalOcean

TODO

## Amazon S3

Assets (css, js, image) are uploaded to Amazon S3.
- Production assets are uploded to the `rudy-production` bucket.
- Staging assets are uploaded to the `rudy-staging` bucket.

The `rudy-staging` bucket is located in Tokyo region. We will see how it
performs to determine where to locate the `rudy-production`.

## CloudFront

The `rudy-production` and `rudy-staging` buckets are replicated worldwide
with Amazon [CloudFront](https://console.aws.amazon.com/cloudfront/) CDN.
- The current production distribution is `TBD`.
- The current staging distribution is `d2timokq6uoxgq.cloudfront.net`.
