/**
 * Tango Neovim — TypeScript syntax showcase.
 *
 * A syntax showcase, not production code. It exercises the TypeScript grammar
 * broadly enough to hit every highlight group the Tango theme defines, while
 * still reading like a believable slice of a backend — a ride-hailing service
 * with a fleet, a booking ledger and a payment gateway.
 *
 * Sections: enums -> aliases -> generics -> utility types -> errors ->
 * decorators -> value objects -> repositories -> services -> bootstrap.
 */

import type { Logger } from './container';

// ---------------------------------------------------------------------------
// Enums and namespaces
// ---------------------------------------------------------------------------

/** Lifecycle of a single ride request. Backed by the numeric default. */
export enum BookingStatus {
  Draft,
  Searching,
  Accepted,
  Arriving,
  InProgress,
  Settled,
}

/** Vehicles are a closed set; string members keep logs readable. */
export enum VehicleClass {
  Economy = 'economy',
  Comfort = 'comfort',
  Van = 'van',
}

/** Operational severity, ordered for the audit pipeline. */
export const enum Severity {
  Trace,
  Info,
  Warn,
  Critical,
}

/** Well-known error codes shared with the mobile clients. */
export namespace NimbusErrorCodes {
  export const DriverUnavailable = 'driver_unavailable';
  export const FareQuotationExpired = 'fare_quotation_expired';
  export const PaymentDeclined = 'payment_declined';

  export function isFatal(code: string): boolean {
    return code === PaymentDeclined || code === DriverUnavailable;
  }
}

/** Prices are integers in minor units; never floats. */
export type MinorUnits = number;
export type CurrencyCode = 'USD' | 'EUR' | 'INR' | 'GBP';
export type BookingId = string;
export type DriverId = string;

/** (latitude, longitude) — labelled so call sites are self-documenting. */
export type LatLng = readonly [lat: number, lng: number];

/** A fare breakdown that the client renders, in minor units. */
export type FareParts = readonly [base: number, distance: number, surge: number];

/** Geographic point with identity, so it can live in a repository. */
export interface Identifiable {
  readonly id: string;
}

/** Ordered collection contract used by the in-memory repositories. */
export interface Repository<T extends Identifiable, TFilter = void> {
  readonly name: string;
  size(): number;
  get(id: string): T | undefined;
  list(filter?: TFilter): readonly T[];
  save(entity: T): T;
  remove(id: string): boolean;
}

/** Payment handles are opaque; never log them. */
export type PaymentMethodId = string & { readonly __brand: 'PaymentMethod' };

/** Everything the gateway knows about a rider. */
export type RiderProfile = {
  readonly id: string;
  readonly displayName: string;
  readonly rating: number;
  readonly home?: LatLng;
  readonly paymentMethods: readonly PaymentMethodId[];
};

/** A rider is verified once they carry a non-zero rating. */
export function isVerifiedRider(rider: RiderProfile): rider is RiderProfile & { rating: number } {
  return rider.rating > 0 && Number.isFinite(rider.rating);
}

// ---------------------------------------------------------------------------
// Utility, mapped and conditional types
// ---------------------------------------------------------------------------

/** Unwrap `Promise<T>` — handy when threading async results through generics. */
export type Awaitedish<T> = T extends Promise<infer U> ? U : T;

/** Same as `Partial`, spelled out so the mapped-type syntax stays visible. */
export type Mutable<T> = { -readonly [K in keyof T]: T[K] };

/** Recursively strip mutability from a quote payload. */
export type DeepReadonly<T> = T extends (infer R)[]
  ? readonly DeepReadonly<R>[]
  : T extends object
    ? { readonly [K in keyof T]: DeepReadonly<T[K]> }
    : T;

/** The mutable subset of a vehicle an operator may edit. */
export type VehiclePatch = Partial<Pick<Vehicle, 'plate' | 'vehicleClass' | 'location'>> &
  Omit<Vehicle, 'plate' | 'vehicleClass' | 'location'>;

// ---------------------------------------------------------------------------
// keyof, typeof, satisfies and as const
// ---------------------------------------------------------------------------

/** Surge multipliers, frozen so `keyof typeof` sees real literals. */
export const SURGE_TIERS = {
  quiet: 1,
  busy: 1.35,
  surge: 1.9,
  emergency: 2.75,
} as const;

export type SurgeTier = keyof typeof SURGE_TIERS;
export type SurgeMultiplier = (typeof SURGE_TIERS)[SurgeTier];

/** `satisfies` keeps the literal types while still checking completeness. */
export const TIER_ORDER = ['quiet', 'busy', 'surge', 'emergency'] satisfies readonly SurgeTier[];

export interface NimbusConfig {
  readonly currency: CurrencyCode;
  readonly minimumFare: MinorUnits;
  readonly maxBatchSize: number;
  readonly tiers: Readonly<Record<SurgeTier, SurgeMultiplier>>;
}

const CONFIG: NimbusConfig = {
  currency: 'USD',
  minimumFare: 350,
  maxBatchSize: 64,
  tiers: SURGE_TIERS,
};

// ---------------------------------------------------------------------------
// Errors and result containers
// ---------------------------------------------------------------------------

/** Base class for every failure the service raises. */
export class NimbusError extends Error {
  readonly code: string;
  readonly severity: Severity;

  constructor(message: string, code = 'unknown', severity: Severity = Severity.Warn) {
    super(message);
    this.name = new.target.name;
    this.code = code;
    this.severity = severity;
  }
}

/** Raised when no driver can be paired with a request. */
export class NoDriverAvailableError extends NimbusError {
  readonly searchedWithinMetres: number;

  constructor(radius: number, options?: { cause?: unknown }) {
    super(`no idle driver within ${radius}m`, NimbusErrorCodes.DriverUnavailable, Severity.Critical);
    this.searchedWithinMetres = radius;
    if (options?.cause) this.cause = options.cause;
  }
}

/** Railway-style result so callers are not forced into `try/catch`. */
export type Result<T, E extends NimbusError = NimbusError> =
  | { readonly ok: true; readonly value: T }
  | { readonly ok: false; readonly error: E };

export function ok<T>(value: T): Result<T, never> {
  return { ok: true, value };
}

export function err<E extends NimbusError>(error: E): Result<never, E> {
  return { ok: false, error };
}

// ---------------------------------------------------------------------------
// Decorators
// ---------------------------------------------------------------------------

const sink: Logger | undefined = undefined;

/** Time a method without wrapping the body by hand. */
function audit<T>(method: (this: T, ...args: unknown[]) => unknown, context: ClassMethodDecoratorContext) {
  const label = String(context.name);
  return function patched(this: T, ...args: unknown[]): unknown {
    const started = Date.now();
    try {
      return method.apply(this, args);
    } finally {
      sink?.debug?.(`${label} finished in ${Date.now() - started}ms`);
    }
  };
}

/** Mark a field so it never reaches a log sink. */
function redact(_target: undefined, context: ClassFieldDecoratorContext): void {
  context.metadata ??= {};
  Reflect.set(context.metadata, 'redacted', true);
}

class RetryPolicy {
  constructor(readonly attempts: number, readonly backoffMs: number) {}
}

/** Bind a retry policy to a member without changing its signature. */
function retry(policy: RetryPolicy) {
  return function (target: unknown, context: ClassMethodDecoratorContext): void {
    context.addInitializer(function (this: unknown) {
      sink?.info?.(`${String(context.name)} will retry up to ${policy.attempts} times`);
    });
  };
}

// ---------------------------------------------------------------------------
// Value objects
// ---------------------------------------------------------------------------

/** A point on the map with haversine distance and identity caching. */
export class GeoPoint implements Identifiable {
  static readonly EARTH_RADIUS_M = 6_371_000;
  static #cache = new Map<string, GeoPoint>();

  readonly id: string;
  readonly lat: number;
  readonly lng: number;

  private constructor(id: string, lat: number, lng: number) {
    this.id = id;
    this.lat = lat;
    this.lng = lng;
  }

  /** Snaps to six decimal places before caching. */
  static of(lat: number, lng: number): GeoPoint {
    const id = `${lat.toFixed(6)}:${lng.toFixed(6)}`;
    const cached = GeoPoint.#cache.get(id);
    if (cached) return cached;
    const point = new GeoPoint(id, lat, lng);
    GeoPoint.#cache.set(id, point);
    return point;
  }

  get asTuple(): LatLng {
    return [this.lat, this.lng];
  }

  distanceTo(other: GeoPoint): number {
    const dLat = (other.lat - this.lat) * (Math.PI / 180);
    const dLng = (other.lng - this.lng) * (Math.PI / 180);
    const a =
      Math.sin(dLat / 2) ** 2 +
      Math.cos(this.lat * (Math.PI / 180)) * Math.cos(other.lat * (Math.PI / 180)) * Math.sin(dLng / 2) ** 2;
    return 2 * GeoPoint.EARTH_RADIUS_M * Math.asin(Math.sqrt(a));
  }

  toString(): string {
    return `GeoPoint(${this.lat.toFixed(3)}, ${this.lng.toFixed(3)})`;
  }
}

export type DriverStatus = 'idle' | 'engaged' | 'offline';

/** Abstract base for anything that can be assigned a fare. */
export abstract class Priced implements Identifiable {
  protected static totalQuoted = 0;

  constructor(readonly id: string, protected readonly currency: CurrencyCode) {}

  /** Subclasses supply the arithmetic; the base handles bookkeeping. */
  abstract quote(): FareParts;

  get total(): MinorUnits {
    const [base, distance, surge] = this.quote();
    return base + distance + surge;
  }

  protected describe(): string {
    return `${this.constructor.name}#${this.id} ≈ ${this.currency} ${(this.total / 100).toFixed(2)}`;
  }
}

/** A concrete vehicle: plate, class, position and per-kilometre pricing. */
export class Vehicle extends Priced {
  #location!: GeoPoint;
  #meter = 0;

  constructor(id: string, readonly plate: string, readonly model: string, readonly vehicleClass: VehicleClass, readonly ratePerKm: number) {
    super(id, 'USD');
    Priced.totalQuoted += 1;
  }

  get location(): GeoPoint {
    return this.#location;
  }

  set location(next: GeoPoint) {
    if (!Number.isFinite(next.lat) || !Number.isFinite(next.lng)) {
      throw new RangeError('coordinates must be finite');
    }
    this.#location = next;
  }

  get odometerKm(): number {
    return this.#meter;
  }

  @audit
  drive(distanceKm: number, destination: GeoPoint): number {
    this.#meter += distanceKm;
    this.location = destination;
    return this.#meter;
  }

  @audit
  quote(): FareParts {
    const base = 250;
    const distance = Math.round(this.ratePerKm * this.#meter * 100);
    return [base, distance, 0] as const;
  }

  patch(changes: VehiclePatch): this {
    const target = this as unknown as { plate: string; vehicleClass: VehicleClass };
    if (changes.plate) target.plate = changes.plate;
    if (changes.vehicleClass) target.vehicleClass = changes.vehicleClass;
    return this;
  }
}

/** A driver owns a vehicle and tracks availability. */
export class Driver extends Priced {
  readonly createdAt = Date.now();
  #status: DriverStatus = 'idle';

  @redact
  private internalNotes = '';

  constructor(id: DriverId, readonly fullName: string, readonly vehicle: Vehicle) {
    super(id, CONFIG.currency);
  }

  get status(): DriverStatus {
    return this.#status;
  }

  @retry(new RetryPolicy(3, 250))
  async accept(booking: Booking): Promise<boolean> {
    if (this.#status !== 'idle') return false;
    this.#status = 'engaged';
    booking.bindDriver(this);
    return true;
  }

  release(): void {
    this.#status = 'idle';
  }

  quote(): FareParts {
    return this.vehicle.quote();
  }
}

// ---------------------------------------------------------------------------
// Repositories
// ---------------------------------------------------------------------------

/** Generic in-memory repository; `store` stays protected for subclasses. */
export abstract class InMemoryRepository<T extends Identifiable> implements Repository<T> {
  protected readonly store = new Map<string, T>();

  constructor(readonly name: string) {}

  size(): number {
    return this.store.size;
  }

  get(id: string): T | undefined {
    return this.store.get(id);
  }

  abstract list(filter?: unknown): readonly T[];

  save(entity: T): T {
    this.store.set(entity.id, entity);
    return entity;
  }

  remove(id: string): boolean {
    return this.store.delete(id);
  }

  /** Yield the *values* so callers never touch Map internals. */
  *entries(): Generator<T, void, undefined> {
    for (const entity of this.store.values()) yield entity;
  }
}

export class Fleet extends InMemoryRepository<Vehicle> {
  private readonly seen = new Set<VehicleClass>();

  constructor() {
    super('fleet');
  }

  list(filter?: { readonly vehicleClass?: VehicleClass; readonly limit?: number }): readonly Vehicle[] {
    const limit = filter?.limit ?? Number.POSITIVE_INFINITY;
    const out: Vehicle[] = [];
    for (const vehicle of this.store.values()) {
      if (filter?.vehicleClass && vehicle.vehicleClass !== filter.vehicleClass) continue;
      out.push(vehicle);
      if (out.length >= limit) break;
    }
    return out;
  }

  save(entity: Vehicle): Vehicle {
    this.seen.add(entity.vehicleClass);
    return super.save(entity);
  }

  nearestTo(point: GeoPoint, limit = 3): readonly Vehicle[] {
    return this.list()
      .map((vehicle) => ({ vehicle, metres: vehicle.location.distanceTo(point) }))
      .sort((a, b) => a.metres - b.metres)
      .slice(0, limit)
      .map((entry) => entry.vehicle);
  }

  byClass(): Readonly<Record<VehicleClass, number>> {
    const tally: Record<VehicleClass, number> = { [VehicleClass.Economy]: 0, [VehicleClass.Comfort]: 0, [VehicleClass.Van]: 0 };
    for (const vehicle of this.store.values()) tally[vehicle.vehicleClass] = (tally[vehicle.vehicleClass] ?? 0) + 1;
    return tally;
  }
}

export class DriverDirectory extends InMemoryRepository<Driver> {
  private readonly byVehicle = new Map<string, DriverId>();

  list(): readonly Driver[] {
    return [...this.store.values()];
  }

  save(entity: Driver): Driver {
    this.byVehicle.set(entity.vehicle.plate, entity.id);
    return super.save(entity);
  }

  forVehicle(plate: string): Driver | undefined {
    const id = this.byVehicle.get(normalisePlate(plate));
    return id ? this.get(id) : undefined;
  }
}

// ---------------------------------------------------------------------------
// Services
// ---------------------------------------------------------------------------

/** Normalises a plate for lookup. */
export const normalisePlate = (raw: string): string => raw.trim().toUpperCase();

/** Rejects obviously malformed plates. */
export const PLATE_RE = /^[A-Z]{2}[-\s]?\d{2}[-\s]?[A-Z]{1,2}[-\s]?\d{4}$/;

export function assertPlate(raw: string): asserts raw is string {
  if (!PLATE_RE.test(normalisePlate(raw))) {
    throw new TypeError(`plate "${raw}" does not match ${String(PLATE_RE)}`);
  }
}

/** Human-readable booking status. */
export function describeStatus(status: BookingStatus): string {
  switch (status) {
    case BookingStatus.Draft:
      return 'draft';
    case BookingStatus.Searching:
      return 'searching';
    case BookingStatus.Accepted:
    case BookingStatus.Arriving:
      return 'driver assigned';
    case BookingStatus.InProgress:
      return 'in progress';
    default:
      return 'settled';
  }
}

/** Formats minor units; overloads cover the two call styles. */
export function formatMoney(amount: MinorUnits, currency?: CurrencyCode): string;
export function formatMoney(amount: MinorUnits, currency: CurrencyCode, locale: string): string;
export function formatMoney(amount: MinorUnits, currency: CurrencyCode = CONFIG.currency, locale?: string): string {
  const major = (amount / 100).toFixed(2);
  return locale
    ? new Intl.NumberFormat(locale, { style: 'currency', currency }).format(amount / 100)
    : `${currency} ${major}`;
}

/** A quote is valid for 90 seconds; afterwards the client must re-ask. */
export class FareQuote implements Identifiable {
  readonly issuedAt = Date.now();
  readonly expiresAt = this.issuedAt + 90_000;

  constructor(readonly id: string, readonly tier: SurgeTier, readonly amount: MinorUnits, readonly distanceMetres: number) {}

  get expired(): boolean {
    return Date.now() > this.expiresAt;
  }

  /** Optional chaining, nullish coalescing and ternaries, together. */
  get surgeLabel(): string {
    const tier = this.tier ?? 'quiet';
    return tier === 'quiet' ? 'no surge' : `${tier} ×${SURGE_TIERS[tier].toFixed(2)}`;
  }
}

/** Minimal contract the service needs from a payment provider. */
export interface PaymentGatewayLike {
  charge(method: PaymentMethodId, amount: MinorUnits, currency: CurrencyCode): Promise<string>;
  refund(receipt: string): Promise<boolean>;
}

/** A ride once a driver has been assigned. */
export class Booking implements Identifiable {
  #status: BookingStatus = BookingStatus.Draft;
  #driver?: Driver;
  #receipt?: string;

  constructor(readonly id: BookingId, readonly rider: RiderProfile, readonly vehicle: Vehicle, readonly fare: FareParts) {}

  get status(): BookingStatus {
    return this.#status;
  }

  get total(): MinorUnits {
    return this.fare.reduce((sum, part) => sum + part, 0);
  }

  bindDriver(driver: Driver): void {
    if (this.#status !== BookingStatus.Draft) return;
    this.#driver = driver;
    this.#status = BookingStatus.Accepted;
  }

  markSettled(receipt: string): void {
    this.#receipt = receipt;
    this.#status = BookingStatus.Settled;
  }

  cancel(reason: string): void {
    this.#status = BookingStatus.Searching;
    this.#driver?.release();
    sink?.warn?.(`booking ${this.id} cancelled: ${reason}`);
  }

  /** Serialise for the wire; redacted fields never leave the process. */
  toJSON(): Record<string, unknown> {
    return { id: this.id, rider: this.rider.id, total: this.total, receipt: this.#receipt ?? null };
  }
}

/** Ties the fleet, the directory and the gateway together. */
export class BookingService {
  readonly #quotes = new Map<string, FareQuote>();
  readonly #history: Booking[] = [];

  constructor(
    private readonly fleet: Fleet,
    private readonly directory: DriverDirectory,
    private readonly gateway: PaymentGatewayLike,
    private readonly logger?: Logger,
  ) {}

  /**
   * Quote a fare between two points.
   *
   * Returns a railway `Result` so callers branch without a `try/catch`.
   */
  quoteFare(from: GeoPoint, to: GeoPoint, tier: SurgeTier = 'quiet'): Result<FareQuote> {
    const distanceMetres = Math.round(from.distanceTo(to));
    const amount = Math.round(CONFIG.minimumFare * SURGE_TIERS[tier]);
    const quote = new FareQuote(`q_${distanceMetres}_${tier}`, tier, amount, distanceMetres);
    this.#quotes.set(quote.id, quote);
    return ok(quote);
  }

  /** Pair the nearest available driver with a rider. */
  @retry(new RetryPolicy(2, 120))
  @audit
  async dispatch(rider: RiderProfile, to: GeoPoint): Promise<Result<Booking>> {
    const quoted = this.quoteFare(rider.home ?? GeoPoint.of(0, 0), to, 'busy');
    if (!quoted.ok) return err(quoted.error);

    const candidates = this.fleet.nearestTo(to, CONFIG.maxBatchSize);
    for (const vehicle of candidates) {
      const driver = this.directory.forVehicle(vehicle.plate);
      if (!driver || driver.status !== 'idle') continue;

      const booking = new Booking(`b_${Date.now()}`, rider, vehicle, vehicle.quote());
      if (await driver.accept(booking)) {
        this.#history.push(booking);
        return ok(booking);
      }
    }
    return err(new NoDriverAvailableError(25_000, { cause: 'candidates exhausted' }));
  }

  /** Settle a booking, charging through the gateway. */
  async settle(booking: Booking, method: PaymentMethodId): Promise<Result<string>> {
    try {
      const receipt = await this.gateway.charge(method, booking.total, CONFIG.currency);
      booking.markSettled(receipt);
      this.#history.push(booking);
      return ok(receipt);
    } catch (cause) {
      const failed = new NimbusError('charge failed', NimbusErrorCodes.PaymentDeclined, Severity.Critical);
      return err(failed);
    } finally {
      this.logger?.debug?.('settle() finished', { booking: booking.id });
    }
  }

  /** Bulk-cancel: rest args and `for...of`, together. */
  cancel(...ids: readonly BookingId[]): number {
    let cancelled = 0;
    for (const id of ids) {
      const booking = this.#history.find((entry) => entry.id === id);
      if (booking?.status === BookingStatus.Accepted) {
        booking.cancel('bulk');
        cancelled += 1;
      }
    }
    return cancelled;
  }

  /** Introspection used by the /admin/fleet screen. */
  snapshot(): {
    readonly fleet: number;
    readonly drivers: number;
    readonly openQuotes: number;
    readonly byClass: Readonly<Record<VehicleClass, number>>;
  } {
    const openQuotes = [...this.#quotes.values()].filter((quote) => !quote.expired).length;
    return { fleet: this.fleet.size(), drivers: this.directory.size(), openQuotes, byClass: this.fleet.byClass() };
  }
}

// ---------------------------------------------------------------------------
// Domain bootstrap
// ---------------------------------------------------------------------------

const demoGateway: PaymentGatewayLike = {
  async charge(_method: PaymentMethodId, amount: MinorUnits) {
    return `rcpt_${amount}_${Math.random().toString(36).slice(2, 8)}`;
  },
  async refund(_receipt: string) {
    return true;
  },
};

function seedFleet(): Fleet {
  const fleet = new Fleet();
  const seed: readonly [string, string, VehicleClass, number][] = [
    ['KA-01-AB-1234', 'Toyota Etios', VehicleClass.Economy, 12],
    ['KA-05-CD-5678', 'Honda City', VehicleClass.Comfort, 18],
    ['KA-09-EF-9012', 'Maruti Eeco', VehicleClass.Van, 24],
  ];

  for (const [plate, model, vehicleClass, rate] of seed) {
    assertPlate(plate);
    const vehicle = new Vehicle(`v_${plate.slice(-4)}`, plate, model, vehicleClass, rate);
    vehicle.location = GeoPoint.of(12.9716, 77.5946);
    fleet.save(vehicle);
  }
  return fleet;
}

function seedDrivers(fleet: Fleet): DriverDirectory {
  const directory = new DriverDirectory();
  const names = ['Ananya Rao', 'Vikram Shetty', 'Meera Iyer'] as const;
  names.forEach((fullName, index) => directory.save(new Driver(`d_${index + 1}`, fullName, fleet.list()[index])));
  return directory;
}

async function demo(): Promise<void> {
  const fleet = seedFleet();
  const service = new BookingService(fleet, seedDrivers(fleet), demoGateway);
  const rider: RiderProfile = {
    id: 'r_42',
    displayName: 'Rohan Thakur',
    rating: 4.8,
    home: GeoPoint.of(12.9716, 77.5946),
    paymentMethods: ['pm_visa_4242' as PaymentMethodId],
  };

  const destination = GeoPoint.of(13.1986, 77.7066);
  const quoted = service.quoteFare(rider.home!, destination, 'surge');
  console.log(
    `quote ${quoted.ok ? quoted.value.id : 'failed'} · ${quoted.ok ? quoted.value.surgeLabel : 'n/a'}`,
  );

  const booking = await service.dispatch(rider, destination);
  if (booking.ok) {
    const settled = await service.settle(booking.value, rider.paymentMethods[0]);
    console.log(
      `${describeStatus(booking.value.status)} · ${formatMoney(booking.value.total)} -> ${settled.ok ? settled.value : settled.error.message}`,
    );
  } else {
    console.error('dispatch failed:', booking.error.code);
  }

  // Walk the fleet both ways, and the config with `for...in`.
  for (const vehicle of fleet.entries()) {
    console.log(`${vehicle.plate.padEnd(14)} ${vehicle.vehicleClass.padEnd(8)} ${vehicle.odometerKm} km`);
  }
  for (const tier in CONFIG.tiers) console.log(`tier ${tier} = ×${CONFIG.tiers[tier as SurgeTier]}`);
  console.log('snapshot', JSON.stringify(service.snapshot()));
}

void demo().catch((error: unknown) => console.error(error));
